//
//  AddTransactionTypeToggle.swift
//  finance-test-ios
//

import SwiftUI

struct AddTransactionTypeToggle: View {
	let selection: TransactionType
	let onSelect: (TransactionType) -> Void

	var body: some View {
		HStack(spacing: 4) {
			option(.expense, title: "Expense")
			option(.income, title: "Income")
		}
		.padding(4)
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(Color.neutral30)
		)
	}

	private func option(_ type: TransactionType, title: String) -> some View {
		let isSelected = selection == type

		return Button {
			onSelect(type)
		} label: {
			Text(title)
				.font(.baseStyle(size: 14, weight: .bold))
				.foregroundStyle(isSelected ? .white : .neutral70)
				.frame(maxWidth: .infinity)
				.padding(.vertical, 10)
				.background(
					RoundedRectangle(cornerRadius: 9)
						.fill(isSelected ? backgroundColor(for: type) : .clear)
				)
		}
	}

	private func backgroundColor(for type: TransactionType) -> Color {
		switch type {
		case .expense: .dangerMain
		case .income: .successMain
		}
	}
}

#Preview {
	struct PreviewHost: View {
		@State private var selection = TransactionType.expense

		var body: some View {
			AddTransactionTypeToggle(selection: selection) { selection = $0 }
				.padding()
		}
	}

	return PreviewHost()
}
