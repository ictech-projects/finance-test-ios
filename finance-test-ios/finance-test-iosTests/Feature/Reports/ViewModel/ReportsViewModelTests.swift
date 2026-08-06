//
//  ReportsViewModelTests.swift
//  finance-test-iosTests
//

import Foundation
import Testing
@testable import finance_test_ios

@Suite("ReportsViewModel")
@MainActor
final class ReportsViewModelTests: MemoryLeakTrackingSuite {

	// MARK: - onLoad

	@Test
	func onLoad_success_populatesSummaryAndTopExpenses() async {
		let food = anyCategoryItem(id: "food", name: "Food", type: .expense)
		let salary = anyCategoryItem(id: "salary", name: "Salary", type: .income)
		let transactions = [
			anyTransactionItem(id: "1", categoryId: "food", type: .expense, amount: "30", transactionDate: "2026-07-10"),
			anyTransactionItem(id: "2", categoryId: "food", type: .expense, amount: "20", transactionDate: "2026-07-15"),
			anyTransactionItem(id: "3", categoryId: "salary", type: .income, amount: "500", transactionDate: "2026-07-20")
		]
		let sut = makeSUT(
			transactionRepository: TransactionMockRepository(result: .loaded(anyTransactionListSuccessResponse(items: transactions))),
			categoryRepository: TransactionCategoryMockRepository(result: .loaded(anyCategoryListSuccessResponse(items: [food, salary])))
		)

		await sut.onLoad()

		#expect(sut.viewState == .loaded)
		#expect(sut.summary.totalExpense == 50)
		#expect(sut.summary.totalIncome == 500)
		#expect(sut.topExpenses.count == 2)
		#expect(sut.topExpenses.first?.amountLabel == "-$30.00")
	}

	@Test
	func onLoad_whenTransactionsRepositoryErrors_setsErrorState() async {
		let sut = makeSUT(
			transactionRepository: TransactionMockRepository(result: .error(NSError(domain: "", code: -1)))
		)

		await sut.onLoad()

		#expect(sut.viewState == .error)
	}

	@Test
	func onLoad_defaultsPeriodToMostRecentTransactionMonth() async {
		let transactions = [
			anyTransactionItem(id: "1", transactionDate: "2026-05-10"),
			anyTransactionItem(id: "2", transactionDate: "2026-07-27"),
			anyTransactionItem(id: "3", transactionDate: "2026-06-01")
		]
		let sut = makeSUT(
			transactionRepository: TransactionMockRepository(result: .loaded(anyTransactionListSuccessResponse(items: transactions)))
		)

		await sut.onLoad()

		let calendar = Calendar.current
		#expect(calendar.component(.month, from: sut.periodDate) == 7)
		#expect(calendar.component(.year, from: sut.periodDate) == 2026)
	}

	// MARK: - selectPeriodMode

	@Test
	func selectPeriodMode_switchingToYearly_includesTransactionsAcrossWholeYear() async {
		let transactions = [
			anyTransactionItem(id: "1", type: .expense, amount: "10", transactionDate: "2026-01-05"),
			anyTransactionItem(id: "2", type: .expense, amount: "20", transactionDate: "2026-07-27")
		]
		let sut = makeSUT(
			transactionRepository: TransactionMockRepository(result: .loaded(anyTransactionListSuccessResponse(items: transactions)))
		)
		await sut.onLoad()
		#expect(sut.summary.totalExpense == 20)

		sut.selectPeriodMode(.yearly)

		#expect(sut.summary.totalExpense == 30)
	}

	// MARK: - Period navigation

	@Test
	func goToNextPeriod_movesForwardByMonthInMonthlyMode() async {
		let sut = makeSUT(
			transactionRepository: TransactionMockRepository(
				result: .loaded(anyTransactionListSuccessResponse(items: [anyTransactionItem(transactionDate: "2026-07-27")]))
			)
		)
		await sut.onLoad()

		sut.goToNextPeriod()

		let calendar = Calendar.current
		#expect(calendar.component(.month, from: sut.periodDate) == 8)
		#expect(calendar.component(.year, from: sut.periodDate) == 2026)
	}

	@Test
	func goToPreviousPeriod_movesBackByYearInYearlyMode() async {
		let sut = makeSUT(
			transactionRepository: TransactionMockRepository(
				result: .loaded(anyTransactionListSuccessResponse(items: [anyTransactionItem(transactionDate: "2026-07-27")]))
			)
		)
		await sut.onLoad()
		sut.selectPeriodMode(.yearly)

		sut.goToPreviousPeriod()

		#expect(Calendar.current.component(.year, from: sut.periodDate) == 2025)
	}

	// MARK: - savingsRate

	@Test
	func savingsRate_whenIncomeIsZero_returnsZeroNotNaN() async {
		let sut = makeSUT(
			transactionRepository: TransactionMockRepository(
				result: .loaded(anyTransactionListSuccessResponse(items: [anyTransactionItem(type: .expense, amount: "10")]))
			)
		)

		await sut.onLoad()

		#expect(sut.savingsRate == 0)
	}

	// MARK: - topExpenses

	@Test
	func topExpenses_sortedDescendingAndCappedAtLimit() async {
		let transactions = (1...6).map { index in
			anyTransactionItem(id: "\(index)", type: .expense, amount: "\(index * 10)", transactionDate: "2026-07-1\(index)")
		}
		let sut = makeSUT(
			transactionRepository: TransactionMockRepository(result: .loaded(anyTransactionListSuccessResponse(items: transactions)))
		)

		await sut.onLoad()

		#expect(sut.topExpenses.count == 5)
		#expect(sut.topExpenses.first?.amountLabel == "-$60.00")
		#expect(sut.topExpenses.last?.amountLabel == "-$20.00")
	}

	// MARK: - Helpers

	private func makeSUT(
		transactionRepository: TransactionMockRepository = TransactionMockRepository(
			result: .loaded(anyTransactionListSuccessResponse())
		),
		categoryRepository: TransactionCategoryMockRepository = TransactionCategoryMockRepository(
			result: .loaded(anyCategoryListSuccessResponse())
		),
		file: StaticString = #filePath,
		line: UInt = #line
	) -> ReportsViewModel {
		let sut = ReportsViewModel(transactionRepository: transactionRepository, categoryRepository: categoryRepository)
		trackForMemoryLeak(sut, file: file, line: line)
		return sut
	}
}
