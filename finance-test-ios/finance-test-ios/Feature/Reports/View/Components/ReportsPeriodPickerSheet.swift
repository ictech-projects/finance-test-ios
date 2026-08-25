//
//  ReportsPeriodPickerSheet.swift
//  finance-test-ios
//

import SwiftUI

/// Lets the user jump straight to an arbitrary month/year instead of stepping one period at a
/// time via `ReportsPeriodSelector`'s chevrons. Owns its own dismissal and reports the chosen
/// period directly on `viewModel`, since this sheet is exclusively used within Reports.
struct ReportsPeriodPickerSheet: View {
	@ObservedObject var viewModel: ReportsViewModel
	@Environment(\.dismiss) private var dismiss

	@State private var selectedYear: Int
	@State private var selectedMonth: Int

	init(viewModel: ReportsViewModel) {
		self.viewModel = viewModel

		let components = Calendar.current.dateComponents([.year, .month], from: viewModel.referenceDate)
		_selectedYear = State(initialValue: components.year ?? Self.currentYear)
		_selectedMonth = State(initialValue: components.month ?? Self.currentMonth)
	}

	private var availableMonths: [Int] {
		selectedYear == Self.currentYear ? Array(1...Self.currentMonth) : Array(1...12)
	}

	private var availableYears: [Int] {
		Array((Self.currentYear - 15)...Self.currentYear)
	}

	var body: some View {
		NavigationStack {
			HStack(spacing: 0) {
				if viewModel.periodType == .monthly {
					Picker("Month", selection: $selectedMonth) {
						ForEach(availableMonths, id: \.self) { month in
							Text(Self.monthName(month)).tag(month)
						}
					}
					.pickerStyle(.wheel)
					.labelsHidden()
				}

				Picker("Year", selection: $selectedYear) {
					ForEach(availableYears, id: \.self) { year in
						Text(String(year)).tag(year)
					}
				}
				.pickerStyle(.wheel)
				.labelsHidden()
			}
			.padding(.horizontal, 16)
			.onChange(of: selectedYear) {
				if !availableMonths.contains(selectedMonth) {
					selectedMonth = availableMonths.last ?? Self.currentMonth
				}
			}
			.navigationTitle(viewModel.periodType == .monthly ? "Select Month" : "Select Year")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") { dismiss() }
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Done") {
						viewModel.selectPeriod(referenceDate: Self.date(year: selectedYear, month: selectedMonth))
						dismiss()
					}
				}
			}
		}
		.presentationDetents([.medium])
	}

	private static var currentYear: Int { Calendar.current.component(.year, from: Date()) }
	private static var currentMonth: Int { Calendar.current.component(.month, from: Date()) }

	private static func date(year: Int, month: Int) -> Date {
		Calendar.current.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
	}

	private static func monthName(_ month: Int) -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US")
		return formatter.monthSymbols[month - 1]
	}
}

#Preview {
	ReportsPeriodPickerSheet(viewModel: ReportsViewModel(reportsRepository: ReportsMockRepository()))
}
