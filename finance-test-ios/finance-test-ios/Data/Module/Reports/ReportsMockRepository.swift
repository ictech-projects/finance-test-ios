//
//  ReportsMockRepository.swift
//  finance-test-ios
//

import Foundation

/// Preview-only stand-in for `ReportsDefaultRepository` — `ReportsViewModel` defaults to the real
/// repository, so this type should only ever be injected explicitly from `#Preview` blocks.
struct ReportsMockRepository: ReportsRepository {

	func getPeriodSummary(
		request: Reports.Request.GetPeriodSummary
	) async -> RequestState<GeneralResponse<Reports.Response.PeriodSummary>> {
		try? await Task.sleep(nanoseconds: 400_000_000)

		return .loaded(
			GeneralResponse(
				success: true,
				statusCode: 200,
				message: "Period summary computed.",
				data: Self.summary(for: request)
			)
		)
	}

	/// The canned mocks only ever modeled one month/year. Real navigation needs a summary that
	/// actually reflects `request.referenceDate` — the label/subtitle always do, and the totals
	/// are scaled deterministically so distinct periods look distinct (and are stable if you
	/// navigate back to one you've already seen) without needing a full mock dataset per period.
	private static func summary(for request: Reports.Request.GetPeriodSummary) -> Reports.Response.PeriodSummary {
		let base: Reports.Response.PeriodSummary = switch request.periodType {
		case .monthly: .monthlyMock
		case .yearly: .yearlyMock
		}

		let bounds = ReportsPeriodFormatting.bounds(for: request.periodType, referenceDate: request.referenceDate)
		let scale = Self.amountScale(for: request)

		return Reports.Response.PeriodSummary(
			periodLabel: ReportsPeriodFormatting.label(for: request.periodType, periodStart: bounds.start),
			periodSubtitle: ReportsPeriodFormatting.subtitle(for: request.periodType, bounds: bounds),
			totalIncome: base.totalIncome * scale,
			totalSpent: base.totalSpent * scale,
			netSaved: base.netSaved * scale,
			savingsRatePercent: base.savingsRatePercent,
			categoryBreakdown: base.categoryBreakdown.map { category in
				Reports.Response.CategoryBreakdown(
					categoryId: category.categoryId,
					name: category.name,
					colorHex: category.colorHex,
					totalAmount: category.totalAmount * scale,
					percent: category.percent
				)
			},
			topExpenses: base.topExpenses.map { expense in
				Reports.Response.Expense(
					transactionId: expense.transactionId,
					title: expense.title,
					subtitle: expense.subtitle,
					amount: expense.amount * scale,
					categoryIcon: expense.categoryIcon,
					categoryColorHex: expense.categoryColorHex
				)
			}
		)
	}

	private static func amountScale(for request: Reports.Request.GetPeriodSummary) -> Double {
		let component: Calendar.Component = request.periodType == .monthly ? .month : .year
		let periodsAgo = max(
			0,
			Calendar.current.dateComponents([component], from: request.referenceDate, to: Date()).value(for: component) ?? 0
		)

		let wobble = Double(periodsAgo % 4) * 0.08
		return max(0.55, 1 - Double(periodsAgo) * 0.04 + wobble)
	}
}
