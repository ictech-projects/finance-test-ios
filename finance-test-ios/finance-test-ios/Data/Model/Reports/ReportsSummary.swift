//
//  ReportsSummary.swift
//  finance-test-ios
//

import Foundation

/// One category's contribution to a `ReportsSummary` (a pie-chart slice / legend row).
/// `percentage` (0...100) is relative to the total of transactions sharing `type` — an expense
/// category's percentage is relative to `totalExpense`, an income category's to `totalIncome`.
///
/// Named `Home` rather than `Reports` because the Reports tab has its own, differently-shaped
/// `ReportsCategoryBreakdown` (`Feature/Reports/Model/ReportsCategoryBreakdown.swift`); this one
/// is only consumed by `HomeViewModel` via `ReportsAggregator`.
struct HomeCategoryBreakdown: Equatable, Hashable, Identifiable {
	let categoryId: String
	let categoryName: String
	let icon: String?
	let colorHex: String?
	let type: TransactionType
	let total: Double
	let percentage: Double

	var id: String { categoryId }
}

/// Aggregated totals + category breakdowns produced by `ReportsAggregator.summarize`.
/// Carries no fetching/filtering logic of its own — see `ReportsAggregator`.
struct ReportsSummary: Equatable, Hashable {
	let totalIncome: Double
	let totalExpense: Double
	let netAmount: Double
	let expenseBreakdown: [HomeCategoryBreakdown]
	let incomeBreakdown: [HomeCategoryBreakdown]

	static let empty = ReportsSummary(
		totalIncome: 0, totalExpense: 0, netAmount: 0, expenseBreakdown: [], incomeBreakdown: []
	)
}
