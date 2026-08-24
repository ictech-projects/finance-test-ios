//
//  ReportsExpenseRow.swift
//  finance-test-ios
//

import SwiftUI

struct ReportsExpenseRow: View {
	let expense: ReportsExpenseItem

	var body: some View {
		HStack(spacing: 16) {
			Image(systemName: expense.iconSystemName)
				.font(.baseStyle(size: 16, weight: .semibold))
				.foregroundStyle(expense.iconForeground)
				.frame(width: 40, height: 40)
				.background(
					Circle().fill(expense.iconBackground)
				)

			VStack(alignment: .leading, spacing: 0) {
				Text(expense.title)
					.font(.baseStyle(size: 16, weight: .semibold))
					.foregroundStyle(.addTransactionValueText)

				Text(expense.subtitle)
					.font(.baseStyle(size: 14, weight: .regular))
					.foregroundStyle(.recordsNeutralIconTint)
			}

			Spacer(minLength: 0)

			Text("-\(expense.amount.currencyFormatted())")
				.font(.baseStyle(size: 16, weight: .semibold))
				.foregroundStyle(.reportsNegativeRed)
		}
		.padding(16)
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(Color.reportsExpenseRowBackground)
		)
	}
}

#Preview {
	VStack(spacing: 8) {
		ReportsExpenseRow(expense: ReportsPeriodSummary.monthlyMocks.last!.topExpenses[0])
		ReportsExpenseRow(expense: ReportsPeriodSummary.monthlyMocks.last!.topExpenses[1])
	}
	.padding()
	.background(Color.neutral20)
}
