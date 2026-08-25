//
//  Reports.swift
//  finance-test-ios
//

import Foundation

/// There is no `/reports` domain in the backend contract (only Auth, Accounts, Transactions,
/// Transfers, Liabilities, Liability Payments, User Currencies, Currencies, Categories, Sync).
/// `Reports` has no `TargetType`/`RemoteDataSource` of its own — `ReportsDefaultRepository`
/// computes these models locally from `TransactionRepository` + `TransactionCategoryRepository`.
enum Reports {
	enum PeriodType: String, Codable, Equatable, Hashable {
		case monthly
		case yearly
	}

	enum Request {}
	enum Response {}
}

extension Reports.Request {

	struct GetPeriodSummary: Codable, Equatable {
		let periodType: Reports.PeriodType
		let referenceDate: Date
	}
}

extension Reports.Response {

	struct CategoryBreakdown: Codable, Equatable, Hashable {
		let categoryId: String?
		let name: String?
		let colorHex: String?
		let totalAmount: Double
		let percent: Double
	}

	struct Expense: Codable, Equatable, Hashable {
		let transactionId: String?
		let title: String?
		let subtitle: String?
		let amount: Double
		let categoryIcon: String?
		let categoryColorHex: String?
	}

	struct PeriodSummary: Codable, Equatable, Hashable {
		let periodLabel: String
		let periodSubtitle: String
		let totalIncome: Double
		let totalSpent: Double
		let netSaved: Double
		let savingsRatePercent: Int
		let categoryBreakdown: [CategoryBreakdown]
		let topExpenses: [Expense]
	}
}

extension Reports.Response.PeriodSummary {
	static let monthlyMock = Reports.Response.PeriodSummary(
		periodLabel: "July 2026",
		periodSubtitle: "Month complete",
		totalIncome: 3_940.40,
		totalSpent: 2_960,
		netSaved: 980.40,
		savingsRatePercent: 18,
		categoryBreakdown: [
			Reports.Response.CategoryBreakdown(
				categoryId: "01K3CT0000000000000000CT01", name: "Housing",
				colorHex: "#24389C", totalAmount: 1_243.20, percent: 0.42
			),
			Reports.Response.CategoryBreakdown(
				categoryId: "01K3CT0000000000000000CT04", name: "Groceries",
				colorHex: "#6B7280", totalAmount: 710.40, percent: 0.24
			),
			Reports.Response.CategoryBreakdown(
				categoryId: "01K3CT0000000000000000CT03", name: "Transport",
				colorHex: "#6B7280", totalAmount: 562.40, percent: 0.19
			)
		],
		topExpenses: [
			Reports.Response.Expense(
				transactionId: "01K3TX0000000000000000TX01", title: "Rent payment",
				subtitle: "Housing • Jul 1", amount: 1_800,
				categoryIcon: "house.fill", categoryColorHex: "#24389C"
			),
			Reports.Response.Expense(
				transactionId: "01K3TX0000000000000000TX02", title: "Whole Foods",
				subtitle: "Groceries • Jul 14", amount: 298.60,
				categoryIcon: "cart", categoryColorHex: "#6B7280"
			)
		]
	)

	static let yearlyMock = Reports.Response.PeriodSummary(
		periodLabel: "2026",
		periodSubtitle: "9 months remaining",
		totalIncome: 39_160.90,
		totalSpent: 29_480,
		netSaved: 9_680.90,
		savingsRatePercent: 22,
		categoryBreakdown: [
			Reports.Response.CategoryBreakdown(
				categoryId: "01K3CT0000000000000000CT01", name: "Housing",
				colorHex: "#24389C", totalAmount: 12_086.80, percent: 0.41
			),
			Reports.Response.CategoryBreakdown(
				categoryId: "01K3CT0000000000000000CT04", name: "Groceries",
				colorHex: "#6B7280", totalAmount: 7_370, percent: 0.25
			)
		],
		topExpenses: [
			Reports.Response.Expense(
				transactionId: "01K3TX0000000000000000TX03", title: "Annual insurance",
				subtitle: "Housing • Mar 3", amount: 2_400,
				categoryIcon: "house.fill", categoryColorHex: "#24389C"
			)
		]
	)
}
