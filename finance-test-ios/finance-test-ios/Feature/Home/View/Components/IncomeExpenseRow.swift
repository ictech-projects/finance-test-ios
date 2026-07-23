//
//  IncomeExpenseRow.swift
//  finance-test-ios
//

import SwiftUI

struct IncomeExpenseRow: View {
	enum Kind {
		case income
		case expense

		var title: String {
			switch self {
			case .income: "Income"
			case .expense: "Expense"
			}
		}

		var iconName: String {
			switch self {
			case .income: "arrow.down.left"
			case .expense: "arrow.up.right"
			}
		}

		var tint: Color {
			switch self {
			case .income: .homeSuccess
			case .expense: .homeDanger
			}
		}

		var surface: Color {
			switch self {
			case .income: .successSurface
			case .expense: .dangerSurface
			}
		}
	}

	let kind: Kind
	let amount: Double

	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: kind.iconName)
				.font(.baseStyle(size: 14, weight: .bold))
				.foregroundStyle(kind.tint)
				.frame(width: 32, height: 32)
				.background(RoundedRectangle(cornerRadius: 10).fill(kind.surface))

			Text(kind.title)
				.font(.baseStyle(size: 14, weight: .medium))
				.foregroundStyle(.neutral90)

			Spacer()

			AnimatedAmountText(amount: amount)
				.font(.baseStyle(size: 16, weight: .bold))
				.foregroundStyle(kind.tint)
		}
		.frame(maxWidth: .infinity)
		.cardStyle()
	}
}

#Preview {
	VStack(spacing: 12) {
		IncomeExpenseRow(kind: .income, amount: 5_200)
		IncomeExpenseRow(kind: .expense, amount: 3_100)
	}
	.padding()
}
