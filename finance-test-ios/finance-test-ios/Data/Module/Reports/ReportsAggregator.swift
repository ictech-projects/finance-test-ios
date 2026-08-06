//
//  ReportsAggregator.swift
//  finance-test-ios
//

import Foundation

/// Pure, stateless aggregation of raw transactions + categories into a `ReportsSummary`.
/// Performs no fetching — callers get transactions via `TransactionRepository` and categories via
/// `TransactionCategoryRepository` (see `RecordsViewModel`/`AddTransactionViewModel` for that
/// fetch pattern), then hand both arrays here. Extracted out of any ViewModel so the math is
/// independently unit-testable, matching `RecordsViewModel`'s client-side grouping precedent.
enum ReportsAggregator {

	static let uncategorizedId = "uncategorized"
	private static let uncategorizedName = "Uncategorized"

	/// - Parameters:
	///   - transactions: Items to summarize. Callers are responsible for narrowing this to
	///     whichever period the Reports screen shows (e.g. "this month") — this function has no
	///     date-range awareness of its own.
	///   - categories: Resolves each transaction's `categoryId` into a name/icon/color. Items
	///     with no match (or a nil `categoryId`) are bucketed under `uncategorizedId`.
	static func summarize(
		transactions: [TransactionRecord.Response.TransactionItem],
		categories: [TransactionCategory.Response.CategoryItem]
	) -> ReportsSummary {
		let categoriesById = Dictionary(
			categories.compactMap { category in category.id.map { ($0, category) } },
			uniquingKeysWith: { first, _ in first }
		)

		let amountsByType = Dictionary(grouping: transactions.compactMap { item -> (type: TransactionType, categoryId: String, amount: Double)? in
			guard let type = item.type, let amount = item.amount.flatMap(Double.init) else { return nil }
			return (type: type, categoryId: item.categoryId ?? uncategorizedId, amount: amount)
		}, by: \.type)

		let expenseItems = amountsByType[.expense] ?? []
		let incomeItems = amountsByType[.income] ?? []

		let totalExpense = expenseItems.reduce(0) { $0 + $1.amount }
		let totalIncome = incomeItems.reduce(0) { $0 + $1.amount }

		return ReportsSummary(
			totalIncome: totalIncome,
			totalExpense: totalExpense,
			netAmount: totalIncome - totalExpense,
			expenseBreakdown: breakdown(for: expenseItems, type: .expense, total: totalExpense, categoriesById: categoriesById),
			incomeBreakdown: breakdown(for: incomeItems, type: .income, total: totalIncome, categoriesById: categoriesById)
		)
	}

	private static func breakdown(
		for items: [(type: TransactionType, categoryId: String, amount: Double)],
		type: TransactionType,
		total: Double,
		categoriesById: [String: TransactionCategory.Response.CategoryItem]
	) -> [ReportsCategoryBreakdown] {
		let grouped = Dictionary(grouping: items, by: \.categoryId)

		return grouped.map { categoryId, items in
			let categoryTotal = items.reduce(0) { $0 + $1.amount }
			let category = categoriesById[categoryId]
			let percentage = total == 0 ? 0 : (categoryTotal / total * 100).rounded(toPlaces: 1)

			return ReportsCategoryBreakdown(
				categoryId: categoryId,
				categoryName: category?.name ?? uncategorizedName,
				icon: category?.icon,
				colorHex: category?.color,
				type: type,
				total: categoryTotal,
				percentage: percentage
			)
		}
		.sorted { $0.total > $1.total }
	}
}

private extension Double {
	func rounded(toPlaces places: Int) -> Double {
		let divisor = pow(10, Double(places))
		return (self * divisor).rounded() / divisor
	}
}
