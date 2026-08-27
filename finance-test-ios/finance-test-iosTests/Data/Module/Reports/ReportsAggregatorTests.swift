//
//  ReportsAggregatorTests.swift
//  finance-test-iosTests
//

import Foundation
import Testing
@testable import finance_test_ios

@Suite("ReportsAggregator")
struct ReportsAggregatorTests {

	@Test func summarize_emptyTransactions_returnsEmptySummary() {
		let summary = ReportsAggregator.summarize(transactions: [], categories: [])

		#expect(summary == .empty)
	}

	@Test func summarize_mixedIncomeAndExpense_computesTotalsAndNet() {
		let transactions = [
			anyTransactionItem(id: "1", type: .income, amount: "100"),
			anyTransactionItem(id: "2", type: .income, amount: "50"),
			anyTransactionItem(id: "3", type: .expense, amount: "30"),
			anyTransactionItem(id: "4", type: .expense, amount: "20")
		]

		let summary = ReportsAggregator.summarize(transactions: transactions, categories: [anyUserCategoryItem()])

		#expect(summary.totalIncome == 150)
		#expect(summary.totalExpense == 50)
		#expect(summary.netAmount == 100)
	}

	@Test func summarize_expenseBreakdown_groupsByCategoryAndComputesPercentageOfExpenseTotal() {
		let transactions = [
			anyTransactionItem(id: "1", categoryId: "food", type: .expense, amount: "75"),
			anyTransactionItem(id: "2", categoryId: "transport", type: .expense, amount: "25")
		]
		let categories = [
			anyUserCategoryItem(id: "food", name: "Food", type: .expense),
			anyUserCategoryItem(id: "transport", name: "Transport", type: .expense)
		]

		let summary = ReportsAggregator.summarize(transactions: transactions, categories: categories)

		let food = summary.expenseBreakdown.first { $0.categoryId == "food" }
		let transport = summary.expenseBreakdown.first { $0.categoryId == "transport" }
		#expect(food?.total == 75)
		#expect(food?.percentage == 75)
		#expect(transport?.total == 25)
		#expect(transport?.percentage == 25)
	}

	@Test func summarize_incomeBreakdown_percentageIndependentOfExpenseTotal() {
		let transactions = [
			anyTransactionItem(id: "1", categoryId: "salary", type: .income, amount: "100"),
			anyTransactionItem(id: "2", categoryId: "rent", type: .expense, amount: "900")
		]
		let categories = [
			anyUserCategoryItem(id: "salary", name: "Salary", type: .income),
			anyUserCategoryItem(id: "rent", name: "Rent", type: .expense)
		]

		let summary = ReportsAggregator.summarize(transactions: transactions, categories: categories)

		#expect(summary.incomeBreakdown.first?.percentage == 100)
	}

	@Test func summarize_nilCategoryId_bucketsUnderUncategorized() {
		let transaction = TransactionRecord.Response.TransactionItem(
			id: "1", userId: nil, accountId: nil, categoryId: nil,
			currencyId: nil, exchangeRateToAnchor: nil,
			type: .expense, amount: "10", description: nil,
			transactionDate: "2026-07-27", createdAt: nil, updatedAt: nil, deletedAt: nil
		)

		let summary = ReportsAggregator.summarize(transactions: [transaction], categories: [])

		#expect(summary.expenseBreakdown.count == 1)
		#expect(summary.expenseBreakdown.first?.categoryId == ReportsAggregator.uncategorizedId)
		#expect(summary.expenseBreakdown.first?.categoryName == "Uncategorized")
	}

	@Test func summarize_unmatchedCategoryId_bucketsUnderUncategorized() {
		let transaction = anyTransactionItem(id: "1", categoryId: "does-not-exist", type: .expense, amount: "10")

		let summary = ReportsAggregator.summarize(transactions: [transaction], categories: [anyUserCategoryItem(id: "other")])

		#expect(summary.expenseBreakdown.first?.categoryName == "Uncategorized")
	}

	@Test func summarize_breakdownSortedDescendingByTotal() {
		let transactions = [
			anyTransactionItem(id: "1", categoryId: "small", type: .expense, amount: "10"),
			anyTransactionItem(id: "2", categoryId: "large", type: .expense, amount: "90")
		]
		let categories = [
			anyUserCategoryItem(id: "small", name: "Small", type: .expense),
			anyUserCategoryItem(id: "large", name: "Large", type: .expense)
		]

		let summary = ReportsAggregator.summarize(transactions: transactions, categories: categories)

		#expect(summary.expenseBreakdown.map(\.categoryId) == ["large", "small"])
	}

	@Test func summarize_skipsItemsWithNilTypeOrUnparsableAmount() {
		let nilType = TransactionRecord.Response.TransactionItem(
			id: "1", userId: nil, accountId: nil, categoryId: "food",
			currencyId: nil, exchangeRateToAnchor: nil,
			type: nil, amount: "10", description: nil,
			transactionDate: "2026-07-27", createdAt: nil, updatedAt: nil, deletedAt: nil
		)
		let unparsableAmount = anyTransactionItem(id: "2", categoryId: "food", type: .expense, amount: "not-a-number")
		let valid = anyTransactionItem(id: "3", categoryId: "food", type: .expense, amount: "10")

		let summary = ReportsAggregator.summarize(
			transactions: [nilType, unparsableAmount, valid],
			categories: [anyUserCategoryItem(id: "food")]
		)

		#expect(summary.totalExpense == 10)
	}

	@Test func summarize_singleCategory_percentageIsExactly100NotFloatingPointNoise() {
		let transactions = [anyTransactionItem(id: "1", categoryId: "food", type: .expense, amount: "33.33")]

		let summary = ReportsAggregator.summarize(transactions: transactions, categories: [anyUserCategoryItem(id: "food")])

		#expect(summary.expenseBreakdown.first?.percentage == 100)
	}

	@Test func summarize_zeroExpenseTotal_breakdownPercentageIsZeroNotNaN() {
		let transactions = [anyTransactionItem(id: "1", categoryId: "salary", type: .income, amount: "100")]

		let summary = ReportsAggregator.summarize(transactions: transactions, categories: [anyUserCategoryItem(id: "salary", type: .income)])

		#expect(summary.totalExpense == 0)
		#expect(summary.expenseBreakdown.isEmpty)
	}
}
