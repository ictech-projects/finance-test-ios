//
//  AddExpenseIntentHandlerTests.swift
//  finance-test-iosTests
//

import Foundation
import Testing
@testable import finance_test_ios

@Suite("AddExpenseIntentHandler")
struct AddExpenseIntentHandlerTests {

	private static let fixedDate = ISO8601DateFormatter().date(from: "2026-01-15T00:00:00Z")!

	// MARK: - Auth guard

	@Test
	func addExpense_whenNotLoggedIn_throwsAndSkipsRepositoryCalls() async throws {
		let accountRepository = AccountMockRepository(result: .loaded(anyAccountListSuccessResponse()))
		let categoryRepository = UserCategoryMockRepository(result: .loaded(anyUserCategoryListSuccessResponse(items: [anyUserCategoryItem(type: .expense)])))
		let sut = makeSUT(
			accountRepository: accountRepository,
			categoryRepository: categoryRepository,
			authLocalDataSource: AuthMockLocalDataSource(accessToken: nil)
		)

		await expectThrows(FinanceIntentError.notLoggedIn) {
			try await sut.addExpense(amount: 12, merchant: nil, accountId: nil, categoryId: nil)
		}

		#expect(accountRepository.invocations.isEmpty)
		#expect(categoryRepository.invocations.isEmpty)
	}

	// MARK: - Amount validation

	@Test(arguments: [0, -5])
	func addExpense_whenAmountIsZeroOrNegative_throwsInvalidAmount(amount: Double) async throws {
		let sut = makeSUT()

		await expectThrows(FinanceIntentError.invalidAmount) {
			try await sut.addExpense(amount: amount, merchant: nil, accountId: nil, categoryId: nil)
		}
	}

	// MARK: - Success

	@Test
	func addExpense_success_withNoExplicitAccountOrCategory_usesDefaultsAndBuildsExpectedRequest() async throws {
		let defaultAccount = Account.Response.AccountItem(
			id: "acc-default", userId: nil, userCurrencyId: nil, name: "Cash", notes: nil,
			type: "cash", color: nil, initialBalance: nil, balance: nil,
			isDefault: true, createdAt: nil, updatedAt: nil, deletedAt: nil
		)
		let otherAccount = Account.Response.AccountItem(
			id: "acc-other", userId: nil, userCurrencyId: nil, name: "Main Bank", notes: nil,
			type: "bank_account", color: nil, initialBalance: nil, balance: nil,
			isDefault: false, createdAt: nil, updatedAt: nil, deletedAt: nil
		)
		let category = anyUserCategoryItem(id: "cat-1", name: "Dining", type: .expense)
		let transactionRepository = TransactionMockRepository(
			createTransactionResult: .loaded(GeneralResponse(success: true, statusCode: 200, message: "Applied.", data: anyTransactionItem()))
		)
		let sut = makeSUT(
			transactionRepository: transactionRepository,
			accountRepository: AccountMockRepository(result: .loaded(anyAccountListSuccessResponse(items: [otherAccount, defaultAccount]))),
			categoryRepository: UserCategoryMockRepository(result: .loaded(anyUserCategoryListSuccessResponse(items: [category])))
		)

		let result = try await sut.addExpense(amount: 12, merchant: "  ", accountId: nil, categoryId: nil)

		#expect(transactionRepository.invocations == [
			.createTransaction(TransactionRecord.Request.CreateTransaction(
				accountId: "acc-default",
				categoryId: "cat-1",
				type: .expense,
				amount: "12.00",
				exchangeRateToAnchor: "1",
				description: nil,
				transactionDate: "2026-01-15"
			))
		])
		#expect(result == AddExpenseResult(amount: 12, categoryName: "Dining"))
	}

	@Test
	func addExpense_success_withExplicitAccountAndCategory_usesThoseInsteadOfDefaults() async throws {
		let defaultAccount = Account.Response.AccountItem(
			id: "acc-default", userId: nil, userCurrencyId: nil, name: "Cash", notes: nil,
			type: "cash", color: nil, initialBalance: nil, balance: nil,
			isDefault: true, createdAt: nil, updatedAt: nil, deletedAt: nil
		)
		let chosenAccount = Account.Response.AccountItem(
			id: "acc-chosen", userId: nil, userCurrencyId: nil, name: "Main Bank", notes: nil,
			type: "bank_account", color: nil, initialBalance: nil, balance: nil,
			isDefault: false, createdAt: nil, updatedAt: nil, deletedAt: nil
		)
		let firstCategory = anyUserCategoryItem(id: "cat-first", name: "Dining", type: .expense)
		let chosenCategory = anyUserCategoryItem(id: "cat-chosen", name: "Groceries", type: .expense)
		let transactionRepository = TransactionMockRepository(
			createTransactionResult: .loaded(GeneralResponse(success: true, statusCode: 200, message: "Applied.", data: anyTransactionItem()))
		)
		let sut = makeSUT(
			transactionRepository: transactionRepository,
			accountRepository: AccountMockRepository(result: .loaded(anyAccountListSuccessResponse(items: [defaultAccount, chosenAccount]))),
			categoryRepository: UserCategoryMockRepository(result: .loaded(anyUserCategoryListSuccessResponse(items: [firstCategory, chosenCategory])))
		)

		let result = try await sut.addExpense(amount: 30, merchant: "Whole Foods", accountId: "acc-chosen", categoryId: "cat-chosen")

		#expect(transactionRepository.invocations == [
			.createTransaction(TransactionRecord.Request.CreateTransaction(
				accountId: "acc-chosen",
				categoryId: "cat-chosen",
				type: .expense,
				amount: "30.00",
				exchangeRateToAnchor: "1",
				description: "Whole Foods",
				transactionDate: "2026-01-15"
			))
		])
		#expect(result == AddExpenseResult(amount: 30, categoryName: "Groceries"))
	}

	/// Regression: an explicitly requested category that doesn't match must fail loudly rather
	/// than silently logging the expense under some other category. This is what made every Siri
	/// expense land in "Food & Drink" — the picker offered global-catalog ids, none of which
	/// matched a user category, so resolution fell through to `categories.first`.
	@Test
	func addExpense_whenRequestedCategoryDoesNotMatch_throwsRatherThanSubstituting() async throws {
		let available = anyUserCategoryItem(id: "cat-real", name: "Dining", type: .expense)
		let transactionRepository = TransactionMockRepository()
		let sut = makeSUT(
			transactionRepository: transactionRepository,
			categoryRepository: UserCategoryMockRepository(
				result: .loaded(anyUserCategoryListSuccessResponse(items: [available]))
			)
		)

		await expectThrows(FinanceIntentError.categoryNotFound) {
			try await sut.addExpense(amount: 12, merchant: nil, accountId: nil, categoryId: "cat-from-global-catalog")
		}

		#expect(transactionRepository.invocations.isEmpty)
	}

	// MARK: - Resolution failures

	@Test
	func addExpense_whenNoAccountsAvailable_throwsNoAccountAvailable() async throws {
		let sut = makeSUT(
			accountRepository: AccountMockRepository(result: .loaded(anyAccountListSuccessResponse(items: []))),
			categoryRepository: UserCategoryMockRepository(result: .loaded(anyUserCategoryListSuccessResponse(items: [anyUserCategoryItem(type: .expense)])))
		)

		await expectThrows(FinanceIntentError.noAccountAvailable) {
			try await sut.addExpense(amount: 12, merchant: nil, accountId: nil, categoryId: nil)
		}
	}

	@Test
	func addExpense_whenNoCategoriesAvailable_throwsNoCategoryAvailable() async throws {
		let sut = makeSUT(
			accountRepository: AccountMockRepository(result: .loaded(anyAccountListSuccessResponse())),
			categoryRepository: UserCategoryMockRepository(result: .loaded(anyUserCategoryListSuccessResponse(items: [])))
		)

		await expectThrows(FinanceIntentError.noCategoryAvailable) {
			try await sut.addExpense(amount: 12, merchant: nil, accountId: nil, categoryId: nil)
		}
	}

	// MARK: - Backend error mapping

	@Test
	func addExpense_whenAccountsFetchFails_throwsMappedError() async throws {
		let errorResponse = ErrorResponse(success: false, statusCode: 401, message: "Unauthenticated.", errors: nil)
		let sut = makeSUT(
			accountRepository: AccountMockRepository(result: .error(errorResponse)),
			categoryRepository: UserCategoryMockRepository(result: .loaded(anyUserCategoryListSuccessResponse(items: [anyUserCategoryItem(type: .expense)])))
		)

		await expectThrows(FinanceIntentError.sessionExpired) {
			try await sut.addExpense(amount: 12, merchant: nil, accountId: nil, categoryId: nil)
		}
	}

	@Test
	func addExpense_whenCreateTransactionFails_throwsMappedError() async throws {
		let errorResponse = ErrorResponse(success: false, statusCode: 422, message: "The amount is invalid.", errors: nil)
		let transactionRepository = TransactionMockRepository(createTransactionResult: .error(errorResponse))
		let sut = makeSUT(
			transactionRepository: transactionRepository,
			accountRepository: AccountMockRepository(result: .loaded(anyAccountListSuccessResponse())),
			categoryRepository: UserCategoryMockRepository(result: .loaded(anyUserCategoryListSuccessResponse(items: [anyUserCategoryItem(type: .expense)])))
		)

		await expectThrows(FinanceIntentError.requestFailed(message: "The amount is invalid.")) {
			try await sut.addExpense(amount: 12, merchant: nil, accountId: nil, categoryId: nil)
		}
	}

	// MARK: - Helpers

	private func makeSUT(
		transactionRepository: TransactionMockRepository = TransactionMockRepository(),
		accountRepository: AccountMockRepository = AccountMockRepository(result: .loaded(anyAccountListSuccessResponse())),
		categoryRepository: UserCategoryMockRepository = UserCategoryMockRepository(result: .loaded(anyUserCategoryListSuccessResponse(items: [anyUserCategoryItem(type: .expense)]))),
		authLocalDataSource: AuthMockLocalDataSource = AuthMockLocalDataSource(accessToken: "any-token")
	) -> AddExpenseIntentHandler {
		AddExpenseIntentHandler(
			transactionRepository: transactionRepository,
			accountRepository: accountRepository,
			categoryRepository: categoryRepository,
			authLocalDataSource: authLocalDataSource,
			now: { Self.fixedDate }
		)
	}

	private func expectThrows<T>(
		_ expectedError: FinanceIntentError,
		file: StaticString = #filePath,
		line: UInt = #line,
		_ operation: () async throws -> T
	) async {
		do {
			_ = try await operation()
			Issue.record("Expected \(expectedError) but no error was thrown")
		} catch let error as FinanceIntentError {
			#expect(error == expectedError)
		} catch {
			Issue.record("Expected FinanceIntentError.\(expectedError) but got \(error)")
		}
	}
}
