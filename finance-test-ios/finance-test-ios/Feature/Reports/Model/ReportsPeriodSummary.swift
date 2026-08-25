//
//  ReportsPeriodSummary.swift
//  finance-test-ios
//

import SwiftUI

struct ReportsPeriodSummary {
	let periodLabel: String
	let periodSubtitle: String
	let netSaved: Double
	let savingsRatePercent: Int
	let totalSpent: Double
	let categories: [ReportsCategoryBreakdown]
	let topExpenses: [ReportsExpenseItem]
}

extension ReportsPeriodSummary {
	/// Placeholder shown only while `viewState` is `.initial`/`.loading` — never rendered, since
	/// `ReportsView` gates `loadedContent` (the only reader of `summary`) on `viewState == .loaded`.
	static let empty = ReportsPeriodSummary(
		periodLabel: "", periodSubtitle: "",
		netSaved: 0, savingsRatePercent: 0, totalSpent: 0,
		categories: [], topExpenses: []
	)

	static let monthlyMocks: [ReportsPeriodSummary] = [
		ReportsPeriodSummary(
			periodLabel: "July 2026",
			periodSubtitle: "Month complete",
			netSaved: 980.40,
			savingsRatePercent: 18,
			totalSpent: 2_960,
			categories: [
				ReportsCategoryBreakdown(name: "Housing", percent: 0.42, color: .reportsAccentText),
				ReportsCategoryBreakdown(name: "Groceries", percent: 0.24, color: .recordsChipSelectedBackground),
				ReportsCategoryBreakdown(name: "Transport", percent: 0.19, color: .recordsCardBorder),
				ReportsCategoryBreakdown(name: "Utilities", percent: 0.15, color: .reportsUtilitiesOrange)
			],
			topExpenses: [
				ReportsExpenseItem(
					title: "Rent payment",
					subtitle: "Housing • Jul 1",
					amount: 1_800,
					iconSystemName: "house.fill",
					iconBackground: .addTransactionFabBackground,
					iconForeground: .white
				),
				ReportsExpenseItem(
					title: "Whole Foods",
					subtitle: "Groceries • Jul 14",
					amount: 298.60,
					iconSystemName: "cart.fill",
					iconBackground: .recordsChipSelectedBackground,
					iconForeground: .addTransactionValueText
				)
			]
		),
		ReportsPeriodSummary(
			periodLabel: "August 2026",
			periodSubtitle: "Month complete",
			netSaved: 1_120.75,
			savingsRatePercent: 21,
			totalSpent: 3_080,
			categories: [
				ReportsCategoryBreakdown(name: "Housing", percent: 0.40, color: .reportsAccentText),
				ReportsCategoryBreakdown(name: "Groceries", percent: 0.26, color: .recordsChipSelectedBackground),
				ReportsCategoryBreakdown(name: "Transport", percent: 0.18, color: .recordsCardBorder),
				ReportsCategoryBreakdown(name: "Utilities", percent: 0.16, color: .reportsUtilitiesOrange)
			],
			topExpenses: [
				ReportsExpenseItem(
					title: "Rent payment",
					subtitle: "Housing • Aug 1",
					amount: 1_800,
					iconSystemName: "house.fill",
					iconBackground: .addTransactionFabBackground,
					iconForeground: .white
				),
				ReportsExpenseItem(
					title: "Whole Foods",
					subtitle: "Groceries • Aug 9",
					amount: 315.40,
					iconSystemName: "cart.fill",
					iconBackground: .recordsChipSelectedBackground,
					iconForeground: .addTransactionValueText
				)
			]
		),
		ReportsPeriodSummary(
			periodLabel: "September 2026",
			periodSubtitle: "4 weeks remaining",
			netSaved: 1_450.20,
			savingsRatePercent: 24,
			totalSpent: 3_240,
			categories: [
				ReportsCategoryBreakdown(name: "Housing", percent: 0.40, color: .reportsAccentText),
				ReportsCategoryBreakdown(name: "Groceries", percent: 0.25, color: .recordsChipSelectedBackground),
				ReportsCategoryBreakdown(name: "Transport", percent: 0.19, color: .recordsCardBorder),
				ReportsCategoryBreakdown(name: "Utilities", percent: 0.16, color: .reportsUtilitiesOrange)
			],
			topExpenses: [
				ReportsExpenseItem(
					title: "Rent payment",
					subtitle: "Housing • Sept 1",
					amount: 1_800,
					iconSystemName: "house.fill",
					iconBackground: .addTransactionFabBackground,
					iconForeground: .white
				),
				ReportsExpenseItem(
					title: "Whole Foods",
					subtitle: "Groceries • Sept 12",
					amount: 342.15,
					iconSystemName: "cart.fill",
					iconBackground: .recordsChipSelectedBackground,
					iconForeground: .addTransactionValueText
				)
			]
		)
	]

	static let yearlyMocks: [ReportsPeriodSummary] = [
		ReportsPeriodSummary(
			periodLabel: "2025",
			periodSubtitle: "Year complete",
			netSaved: 11_240.50,
			savingsRatePercent: 19,
			totalSpent: 36_920,
			categories: [
				ReportsCategoryBreakdown(name: "Housing", percent: 0.44, color: .reportsAccentText),
				ReportsCategoryBreakdown(name: "Groceries", percent: 0.23, color: .recordsChipSelectedBackground),
				ReportsCategoryBreakdown(name: "Transport", percent: 0.18, color: .recordsCardBorder),
				ReportsCategoryBreakdown(name: "Utilities", percent: 0.15, color: .reportsUtilitiesOrange)
			],
			topExpenses: [
				ReportsExpenseItem(
					title: "Annual insurance",
					subtitle: "Housing • Mar 3",
					amount: 2_400,
					iconSystemName: "house.fill",
					iconBackground: .addTransactionFabBackground,
					iconForeground: .white
				),
				ReportsExpenseItem(
					title: "Holiday travel",
					subtitle: "Transport • Dec 20",
					amount: 1_180.50,
					iconSystemName: "car.fill",
					iconBackground: .recordsCardBorder,
					iconForeground: .addTransactionValueText
				)
			]
		),
		ReportsPeriodSummary(
			periodLabel: "2026",
			periodSubtitle: "9 months remaining",
			netSaved: 9_680.90,
			savingsRatePercent: 22,
			totalSpent: 29_480,
			categories: [
				ReportsCategoryBreakdown(name: "Housing", percent: 0.41, color: .reportsAccentText),
				ReportsCategoryBreakdown(name: "Groceries", percent: 0.25, color: .recordsChipSelectedBackground),
				ReportsCategoryBreakdown(name: "Transport", percent: 0.18, color: .recordsCardBorder),
				ReportsCategoryBreakdown(name: "Utilities", percent: 0.16, color: .reportsUtilitiesOrange)
			],
			topExpenses: [
				ReportsExpenseItem(
					title: "Rent payment",
					subtitle: "Housing • Sept 1",
					amount: 1_800,
					iconSystemName: "house.fill",
					iconBackground: .addTransactionFabBackground,
					iconForeground: .white
				),
				ReportsExpenseItem(
					title: "Whole Foods",
					subtitle: "Groceries • Sept 12",
					amount: 342.15,
					iconSystemName: "cart.fill",
					iconBackground: .recordsChipSelectedBackground,
					iconForeground: .addTransactionValueText
				)
			]
		)
	]
}
