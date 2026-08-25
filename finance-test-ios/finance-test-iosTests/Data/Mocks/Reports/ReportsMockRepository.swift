//
//  ReportsMockRepository.swift
//  finance-test-iosTests
//

import Foundation
@testable import finance_test_ios

/// Test double for `ReportsRepository`, distinct from the app target's `ReportsMockRepository`
/// (which stands in for the real aggregation logic in `#Preview` blocks). This one lets each test
/// configure an arbitrary `RequestState` result and records invocations for assertions.
final class ReportsMockRepository: ReportsRepository {

	enum Invocation: Equatable {
		case getPeriodSummary(Reports.Request.GetPeriodSummary)
	}

	private(set) var invocations: [Invocation] = []

	private let result: RequestState<GeneralResponse<Reports.Response.PeriodSummary>>

	init(result: RequestState<GeneralResponse<Reports.Response.PeriodSummary>> = .idle) {
		self.result = result
	}

	func getPeriodSummary(
		request: Reports.Request.GetPeriodSummary
	) async throws -> RequestState<GeneralResponse<Reports.Response.PeriodSummary>> {
		invocations.append(.getPeriodSummary(request))
		return result
	}
}

/// Fixed on a past month so `ReportsViewModel.canGoToNextPeriod` reliably reads `true` for it,
/// and so it lines up with `anyTransactionItem()`'s hardcoded `"2026-07-27"` transaction date.
func anyReferenceDate(year: Int = 2026, month: Int = 7, day: Int = 15) -> Date {
	Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
}

func anyGetPeriodSummaryRequest(
	periodType: Reports.PeriodType = .monthly,
	referenceDate: Date = anyReferenceDate()
) -> Reports.Request.GetPeriodSummary {
	Reports.Request.GetPeriodSummary(periodType: periodType, referenceDate: referenceDate)
}

func anyCategoryBreakdown(
	categoryId: String? = "01K3CT0000000000000000CT01",
	name: String? = "Housing",
	colorHex: String? = "#24389C",
	totalAmount: Double = 100,
	percent: Double = 0.5
) -> Reports.Response.CategoryBreakdown {
	Reports.Response.CategoryBreakdown(
		categoryId: categoryId, name: name, colorHex: colorHex, totalAmount: totalAmount, percent: percent
	)
}

func anyExpense(
	transactionId: String? = "01K3TX0000000000000000TX01",
	title: String? = "Rent payment",
	subtitle: String? = "Housing • Jul 1",
	amount: Double = 1_800,
	categoryIcon: String? = "house.fill",
	categoryColorHex: String? = "#24389C"
) -> Reports.Response.Expense {
	Reports.Response.Expense(
		transactionId: transactionId, title: title, subtitle: subtitle,
		amount: amount, categoryIcon: categoryIcon, categoryColorHex: categoryColorHex
	)
}

func anyPeriodSummary(
	periodLabel: String = "July 2026",
	periodSubtitle: String = "Month complete",
	totalIncome: Double = 3_940.40,
	totalSpent: Double = 2_960,
	netSaved: Double = 980.40,
	savingsRatePercent: Int = 18,
	categoryBreakdown: [Reports.Response.CategoryBreakdown] = [anyCategoryBreakdown()],
	topExpenses: [Reports.Response.Expense] = [anyExpense()]
) -> Reports.Response.PeriodSummary {
	Reports.Response.PeriodSummary(
		periodLabel: periodLabel, periodSubtitle: periodSubtitle, totalIncome: totalIncome,
		totalSpent: totalSpent, netSaved: netSaved, savingsRatePercent: savingsRatePercent,
		categoryBreakdown: categoryBreakdown, topExpenses: topExpenses
	)
}

func anyPeriodSummarySuccessResponse(
	data: Reports.Response.PeriodSummary? = anyPeriodSummary()
) -> GeneralResponse<Reports.Response.PeriodSummary> {
	GeneralResponse(success: true, statusCode: 200, message: "Period summary computed.", data: data)
}
