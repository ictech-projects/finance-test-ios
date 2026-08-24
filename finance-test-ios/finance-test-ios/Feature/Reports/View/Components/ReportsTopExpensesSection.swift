//
//  ReportsTopExpensesSection.swift
//  finance-test-ios
//

import SwiftUI

struct ReportsTopExpensesSection: View {
	let expenses: [ReportsExpenseItem]

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("Top Expenses")
				.font(.baseStyle(size: 16, weight: .semibold))
				.foregroundStyle(.addTransactionValueText)

			VStack(spacing: 8) {
				ForEach(expenses) { expense in
					ReportsExpenseRow(expense: expense)
						.transition(.opacity.combined(with: .scale(scale: 0.95)))
				}
			}
		}
	}
}

#Preview {
	ReportsTopExpensesSection(expenses: ReportsPeriodSummary.monthlyMocks.last!.topExpenses)
		.padding()
		.background(Color.neutral20)
}
