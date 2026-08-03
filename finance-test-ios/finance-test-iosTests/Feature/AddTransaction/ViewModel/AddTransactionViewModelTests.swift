//
//  AddTransactionViewModelTests.swift
//  finance-test-iosTests
//

import Foundation
import Testing
@testable import finance_test_ios

@Suite("AddTransactionViewModel")
@MainActor
final class AddTransactionViewModelTests: MemoryLeakTrackingSuite {

	// MARK: - onLoad

	@Test
	func onLoad_success_populatesAccountsCategoriesAndDefaults() async {
		let account = anyAccountItem(id: "acc1", name: "Cash")
		let category = anyCategoryItem(id: "cat1", type: .expense)
		let sut = makeSUT(
			categoryRepository: TransactionCategoryMockRepository(
				result: .loaded(anyCategoryListSuccessResponse(items: [category]))
			),
			accountRepository: AccountMockRepository(
				result: .loaded(anyAccountListSuccessResponse(items: [account]))
			)
		)

		await sut.onLoad()

		#expect(sut.viewState == .loaded)
		#expect(sut.accounts == [account])
		#expect(sut.categories == [category])
		#expect(sut.selectedAccount == account)
		#expect(sut.selectedCategory == category)
	}

	@Test
	func onLoad_whenCategoriesRepositoryErrors_setsErrorState() async {
		let sut = makeSUT(
			categoryRepository: TransactionCategoryMockRepository(result: .error(NSError(domain: "", code: -1)))
		)

		await sut.onLoad()

		#expect(sut.viewState == .error)
	}

	@Test
	func onLoad_whenAccountsRepositoryErrors_setsErrorState() async {
		let sut = makeSUT(
			accountRepository: AccountMockRepository(result: .error(NSError(domain: "", code: -1)))
		)

		await sut.onLoad()

		#expect(sut.viewState == .error)
	}

	// MARK: - selectType

	@Test
	func selectType_switchingToIncome_selectsFirstMatchingCategory() async {
		let expenseCategory = anyCategoryItem(id: "cat-expense", type: .expense)
		let incomeCategory = anyCategoryItem(id: "cat-income", type: .income)
		let sut = makeSUT(
			categoryRepository: TransactionCategoryMockRepository(
				result: .loaded(anyCategoryListSuccessResponse(items: [expenseCategory, incomeCategory]))
			)
		)
		await sut.onLoad()

		sut.selectType(.income)

		#expect(sut.type == .income)
		#expect(sut.selectedCategory == incomeCategory)
	}

	// MARK: - selectAccount / selectCategory

	@Test
	func selectAccount_updatesSelectionClearsErrorAndDismissesPicker() async {
		let sut = makeSUT()
		await sut.onLoad()
		let newAccount = anyAccountItem(id: "acc2", name: "Main Bank")

		sut.selectAccount(newAccount)

		#expect(sut.selectedAccount == newAccount)
		#expect(sut.accountErrorMessage == nil)
		#expect(sut.isAccountPickerPresented == false)
	}

	@Test
	func selectCategory_updatesSelectionAndClearsError() async {
		let sut = makeSUT()
		await sut.onLoad()
		let newCategory = anyCategoryItem(id: "cat2", type: .expense)

		sut.selectCategory(newCategory)

		#expect(sut.selectedCategory == newCategory)
		#expect(sut.categoryErrorMessage == nil)
	}

	// MARK: - amountDidChange

	@Test
	func amountDidChange_clearsExistingAmountError() async {
		let transactionRepository = TransactionMockRepository()
		let sut = makeSUT(transactionRepository: transactionRepository)
		await sut.onLoad()
		await sut.save()
		#expect(sut.amountErrorMessage != nil)

		sut.amountText = "5"
		sut.amountDidChange()

		#expect(sut.amountErrorMessage == nil)
	}

	// MARK: - save (validation)

	@Test
	func save_withEmptyAmount_setsErrorAndSkipsRepositoryCall() async {
		let transactionRepository = TransactionMockRepository()
		let sut = makeSUT(transactionRepository: transactionRepository)
		await sut.onLoad()
		sut.amountText = ""

		await sut.save()

		#expect(sut.amountErrorMessage != nil)
		#expect(transactionRepository.invocations.isEmpty)
	}

	@Test
	func save_withNonNumericAmount_setsErrorAndSkipsRepositoryCall() async {
		let transactionRepository = TransactionMockRepository()
		let sut = makeSUT(transactionRepository: transactionRepository)
		await sut.onLoad()
		sut.amountText = "not-a-number"

		await sut.save()

		#expect(sut.amountErrorMessage != nil)
		#expect(transactionRepository.invocations.isEmpty)
	}

	@Test
	func save_withNoAccountsAvailable_setsAccountErrorAndSkipsRepositoryCall() async {
		let transactionRepository = TransactionMockRepository()
		let sut = makeSUT(
			transactionRepository: transactionRepository,
			accountRepository: AccountMockRepository(result: .loaded(anyAccountListSuccessResponse(items: [])))
		)
		await sut.onLoad()
		sut.amountText = "10.00"

		await sut.save()

		#expect(sut.accountErrorMessage != nil)
		#expect(transactionRepository.invocations.isEmpty)
	}

	@Test
	func save_withNoCategoriesAvailable_setsCategoryErrorAndSkipsRepositoryCall() async {
		let transactionRepository = TransactionMockRepository()
		let sut = makeSUT(
			transactionRepository: transactionRepository,
			categoryRepository: TransactionCategoryMockRepository(
				result: .loaded(anyCategoryListSuccessResponse(items: []))
			)
		)
		await sut.onLoad()
		sut.amountText = "10.00"

		await sut.save()

		#expect(sut.categoryErrorMessage != nil)
		#expect(transactionRepository.invocations.isEmpty)
	}

	// MARK: - save (success / failure)

	@Test
	func save_success_callsRepositoryWithMappedRequestAndNotifiesDelegate() async {
		let account = anyAccountItem(id: "acc1")
		let category = anyCategoryItem(id: "cat1", type: .expense)
		let createdItem = anyTransactionItem(id: "created1")
		let transactionRepository = TransactionMockRepository(
			createTransactionResult: .loaded(
				GeneralResponse(success: true, statusCode: 200, message: "Transaction created.", data: createdItem)
			)
		)
		let delegate = AddTransactionDelegateSpy()
		let fixedDate = Date(timeIntervalSince1970: 1_753_574_400) // 2025-07-27 UTC
		let sut = makeSUT(
			date: fixedDate,
			transactionRepository: transactionRepository,
			categoryRepository: TransactionCategoryMockRepository(
				result: .loaded(anyCategoryListSuccessResponse(items: [category]))
			),
			accountRepository: AccountMockRepository(
				result: .loaded(anyAccountListSuccessResponse(items: [account]))
			),
			delegate: delegate
		)
		await sut.onLoad()
		sut.amountText = "42.50"
		sut.note = "Lunch"

		await sut.save()

		#expect(
			transactionRepository.invocations == [
				.createTransaction(
					TransactionRecord.Request.CreateTransaction(
						accountId: "acc1", categoryId: "cat1", type: .expense, amount: "42.50",
						exchangeRateToAnchor: "1", description: "Lunch",
						transactionDate: Self.wireDateFormatter.string(from: fixedDate)
					)
				)
			]
		)
		#expect(delegate.createdItems == [createdItem])
		#expect(sut.isSaving == false)
		#expect(sut.isSaveErrorPresented == false)
	}

	@Test
	func save_withEmptyNote_sendsNilDescription() async {
		let account = anyAccountItem(id: "acc1")
		let category = anyCategoryItem(id: "cat1", type: .expense)
		let transactionRepository = TransactionMockRepository(
			createTransactionResult: .loaded(
				GeneralResponse(success: true, statusCode: 200, message: "Transaction created.", data: anyTransactionItem())
			)
		)
		let sut = makeSUT(
			transactionRepository: transactionRepository,
			categoryRepository: TransactionCategoryMockRepository(
				result: .loaded(anyCategoryListSuccessResponse(items: [category]))
			),
			accountRepository: AccountMockRepository(
				result: .loaded(anyAccountListSuccessResponse(items: [account]))
			)
		)
		await sut.onLoad()
		sut.amountText = "10.00"
		sut.note = ""

		await sut.save()

		guard case .createTransaction(let request) = transactionRepository.invocations.first else {
			Issue.record("Expected exactly one createTransaction invocation")
			return
		}
		#expect(request.description == nil)
	}

	@Test(arguments: [401, 422, 500])
	func save_whenRepositoryReturnsErrorResponse_showsAlertWithBackendMessage(statusCode: Int) async {
		let account = anyAccountItem(id: "acc1")
		let category = anyCategoryItem(id: "cat1", type: .expense)
		let expectedError = ErrorResponse(
			success: false, statusCode: statusCode, message: "The selected account or category is invalid.", errors: nil
		)
		let transactionRepository = TransactionMockRepository(createTransactionResult: .error(expectedError))
		let sut = makeSUT(
			transactionRepository: transactionRepository,
			categoryRepository: TransactionCategoryMockRepository(
				result: .loaded(anyCategoryListSuccessResponse(items: [category]))
			),
			accountRepository: AccountMockRepository(
				result: .loaded(anyAccountListSuccessResponse(items: [account]))
			)
		)
		await sut.onLoad()
		sut.amountText = "10.00"

		await sut.save()

		#expect(sut.isSaveErrorPresented == true)
		#expect(sut.saveErrorMessage == "The selected account or category is invalid.")
		#expect(sut.isSaving == false)
	}

	@Test
	func save_whenRepositoryThrowsGenericError_showsGenericAlertMessage() async {
		let account = anyAccountItem(id: "acc1")
		let category = anyCategoryItem(id: "cat1", type: .expense)
		let transactionRepository = TransactionMockRepository(createTransactionResult: .error(NSError(domain: "TestError", code: 999)))
		let sut = makeSUT(
			transactionRepository: transactionRepository,
			categoryRepository: TransactionCategoryMockRepository(
				result: .loaded(anyCategoryListSuccessResponse(items: [category]))
			),
			accountRepository: AccountMockRepository(
				result: .loaded(anyAccountListSuccessResponse(items: [account]))
			)
		)
		await sut.onLoad()
		sut.amountText = "10.00"

		await sut.save()

		#expect(sut.isSaveErrorPresented == true)
		#expect(sut.saveErrorMessage == "Something went wrong. Please try again.")
		#expect(sut.isSaving == false)
	}

	// MARK: - Helpers

	private static let wireDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(identifier: "UTC")
		return formatter
	}()

	private func makeSUT(
		date: Date = Date(),
		transactionRepository: TransactionMockRepository = TransactionMockRepository(),
		categoryRepository: TransactionCategoryMockRepository = TransactionCategoryMockRepository(
			result: .loaded(anyCategoryListSuccessResponse())
		),
		accountRepository: AccountMockRepository = AccountMockRepository(
			result: .loaded(anyAccountListSuccessResponse())
		),
		delegate: AddTransactionDelegateSpy = AddTransactionDelegateSpy(),
		file: StaticString = #filePath,
		line: UInt = #line
	) -> AddTransactionViewModel {
		let sut = AddTransactionViewModel(
			date: date,
			transactionRepository: transactionRepository,
			categoryRepository: categoryRepository,
			accountRepository: accountRepository,
			delegate: delegate
		)
		trackForMemoryLeak(sut, file: file, line: line)
		return sut
	}
}

private final class AddTransactionDelegateSpy: AddTransactionDelegate {
	private(set) var createdItems: [TransactionRecord.Response.TransactionItem] = []

	nonisolated init() {}

	func didCreateTransaction(_ item: TransactionRecord.Response.TransactionItem) {
		createdItems.append(item)
	}
}
