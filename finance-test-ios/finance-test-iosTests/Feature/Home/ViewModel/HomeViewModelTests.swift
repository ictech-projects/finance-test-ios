//
//  HomeViewModelTests.swift
//  finance-test-iosTests
//

import Foundation
import Testing
@testable import finance_test_ios

@Suite("HomeViewModel")
@MainActor
final class HomeViewModelTests: MemoryLeakTrackingSuite {

	// MARK: - onLoad

	@Test
	func onLoad_success_computesSummaryFromCurrentMonthTransactionsOnly() async {
		let thisMonthIncome = anyHomeTransactionItem(id: "t1", type: .income, amount: "500.00", date: Self.thisMonthDateString)
		let thisMonthExpense = anyHomeTransactionItem(id: "t2", type: .expense, amount: "200.00", date: Self.thisMonthDateString)
		let lastYearExpense = anyHomeTransactionItem(id: "t3", type: .expense, amount: "9999.00", date: "2020-01-15")
		let repository = TransactionMockRepository(
			result: .loaded(anyTransactionListSuccessResponse(items: [thisMonthIncome, thisMonthExpense, lastYearExpense]))
		)
		let sut = makeSUT(transactionRepository: repository)

		await sut.onLoad()

		#expect(sut.viewState == .loaded)
		#expect(sut.summary.income == 500)
		#expect(sut.summary.expense == 200)
		#expect(sut.summary.balanceThisMonth == 300)
	}

	@Test
	func onLoad_success_computesNetWorthSubtractingCreditCardBalance() async {
		let cash = anyAccountItem(id: "acc1", name: "Cash", type: "cash")
		let creditCard = Account.Response.AccountItem(
			id: "acc2", userId: "user1", userCurrencyId: "cur1", name: "Credit Card", notes: nil,
			type: "credit_card", color: "#6B7280", initialBalance: "0", balance: "300",
			isDefault: false, createdAt: nil, updatedAt: nil, deletedAt: nil
		)
		let repository = AccountMockRepository(result: .loaded(anyAccountListSuccessResponse(items: [cash, creditCard])))
		let sut = makeSUT(accountRepository: repository)

		await sut.onLoad()

		// Cash balance (320, from `anyAccountItem`'s default) minus the credit card's owed balance (300).
		#expect(sut.summary.netWorth == 20)
	}

	@Test
	func onLoad_success_mapsExpenseBreakdownIntoCategoriesAndLimitsRecentTransactions() async {
		let category = anyCategoryItem(id: "cat1", name: "Transport", type: .expense)
		let items = (0..<8).map { index in
			anyHomeTransactionItem(id: "t\(index)", categoryId: "cat1", type: .expense, amount: "10.00", date: Self.thisMonthDateString)
		}
		let transactionRepository = TransactionMockRepository(result: .loaded(anyTransactionListSuccessResponse(items: items)))
		let categoryRepository = TransactionCategoryMockRepository(result: .loaded(anyCategoryListSuccessResponse(items: [category])))
		let sut = makeSUT(transactionRepository: transactionRepository, categoryRepository: categoryRepository)

		await sut.onLoad()

		#expect(sut.categories.count == 1)
		#expect(sut.categories.first?.name == "Transport")
		#expect(sut.categories.first?.percent == 1.0)
		#expect(sut.transactions.count == 5)
	}

	@Test
	func onLoad_whenTransactionsRepositoryErrors_setsErrorState() async {
		let sut = makeSUT(transactionRepository: TransactionMockRepository(result: .error(NSError(domain: "", code: -1))))

		await sut.onLoad()

		#expect(sut.viewState == .error)
	}

	@Test
	func onLoad_whenCategoriesRepositoryErrors_setsErrorState() async {
		let sut = makeSUT(categoryRepository: TransactionCategoryMockRepository(result: .error(NSError(domain: "", code: -1))))

		await sut.onLoad()

		#expect(sut.viewState == .error)
	}

	@Test
	func onLoad_whenAccountsRepositoryErrors_setsErrorState() async {
		let sut = makeSUT(accountRepository: AccountMockRepository(result: .error(NSError(domain: "", code: -1))))

		await sut.onLoad()

		#expect(sut.viewState == .error)
	}

	// MARK: - Helpers

	/// Always resolves to a date in the current calendar month, regardless of when the suite runs.
	private static let thisMonthDateString: String = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(identifier: "UTC")
		return formatter.string(from: Date())
	}()

	private func makeSUT(
		transactionRepository: TransactionMockRepository = TransactionMockRepository(
			result: .loaded(anyTransactionListSuccessResponse(items: []))
		),
		categoryRepository: TransactionCategoryMockRepository = TransactionCategoryMockRepository(
			result: .loaded(anyCategoryListSuccessResponse(items: []))
		),
		accountRepository: AccountMockRepository = AccountMockRepository(
			result: .loaded(anyAccountListSuccessResponse(items: []))
		),
		file: StaticString = #filePath,
		line: UInt = #line
	) -> HomeViewModel {
		let sut = HomeViewModel(
			transactionRepository: transactionRepository,
			categoryRepository: categoryRepository,
			accountRepository: accountRepository
		)
		trackForMemoryLeak(sut, file: file, line: line)
		return sut
	}
}

private func anyHomeTransactionItem(
	id: String = "01K3TX0000000000000000TX01",
	accountId: String = "01K3AC0000000000000000AC01",
	categoryId: String = "01K3CT0000000000000000CT01",
	type: TransactionType = .expense,
	amount: String = "10.00",
	date: String = "2026-07-27"
) -> TransactionRecord.Response.TransactionItem {
	TransactionRecord.Response.TransactionItem(
		id: id, userId: "01K3US0000000000000000US01",
		accountId: accountId, categoryId: categoryId,
		currencyId: "usd", exchangeRateToAnchor: "1",
		type: type, amount: amount, description: "Test transaction",
		transactionDate: date, createdAt: "\(date)T00:00:00Z", updatedAt: nil, deletedAt: nil
	)
}
