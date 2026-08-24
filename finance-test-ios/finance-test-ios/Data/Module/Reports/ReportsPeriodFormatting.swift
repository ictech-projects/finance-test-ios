//
//  ReportsPeriodFormatting.swift
//  finance-test-ios
//

import Foundation

/// Shared period-bounds/label/subtitle math, used by both `ReportsDefaultRepository` (real
/// aggregation) and `ReportsMockRepository` (canned totals) so a navigated period always reflects
/// its actual `referenceDate`, regardless of which repository is backing the ViewModel.
enum ReportsPeriodFormatting {
	static func bounds(for periodType: Reports.PeriodType, referenceDate: Date, calendar: Calendar = .current) -> DateInterval {
		let component: Calendar.Component = periodType == .monthly ? .month : .year
		return calendar.dateInterval(of: component, for: referenceDate)
			?? DateInterval(start: referenceDate, duration: 0)
	}

	static func label(for periodType: Reports.PeriodType, periodStart: Date) -> String {
		switch periodType {
		case .monthly: monthLabelFormatter.string(from: periodStart)
		case .yearly: yearLabelFormatter.string(from: periodStart)
		}
	}

	static func subtitle(for periodType: Reports.PeriodType, bounds: DateInterval) -> String {
		let now = Date()

		guard bounds.end > now else {
			return periodType == .monthly ? "Month complete" : "Year complete"
		}
		guard bounds.contains(now) else {
			return "Upcoming"
		}

		let daysRemaining = Calendar.current.dateComponents([.day], from: now, to: bounds.end).day ?? 0

		switch periodType {
		case .monthly:
			let weeksRemaining = max(1, Int(ceil(Double(daysRemaining) / 7)))
			return "\(weeksRemaining) week\(weeksRemaining == 1 ? "" : "s") remaining"
		case .yearly:
			let monthsRemaining = max(1, Int(ceil(Double(daysRemaining) / 30)))
			return "\(monthsRemaining) month\(monthsRemaining == 1 ? "" : "s") remaining"
		}
	}

	private static let monthLabelFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "LLLL yyyy"
		return formatter
	}()

	private static let yearLabelFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy"
		return formatter
	}()
}
