//
//  AddTransactionTypeToggle.swift
//  finance-test-ios
//

import SwiftUI

/// Matches the Figma "Income/Expense Toggle" component — a 3-segment pill (Expense/Income/
/// Transfer). Transfer has no data layer yet (see `TransactionType`, which is income/expense
/// only), so it's shown for visual fidelity but disabled rather than silently doing nothing.
struct AddTransactionTypeToggle: View {
	let selection: TransactionType
	let onSelect: (TransactionType) -> Void

	var body: some View {
		HStack(spacing: 0) {
			option(title: "Expense", isSelected: selection == .expense) {
				onSelect(.expense)
			}
			option(title: "Income", isSelected: selection == .income) {
				onSelect(.income)
			}
			option(title: "Transfer", isSelected: false, isDisabled: true) {}
		}
		.padding(4)
		.background(
			Capsule().fill(Color.neutral30)
		)
	}

	private func option(
		title: String,
		isSelected: Bool,
		isDisabled: Bool = false,
		action: @escaping () -> Void
	) -> some View {
		Button(action: action) {
			Text(title)
				.font(.baseStyle(size: 14, weight: .semibold))
				.foregroundStyle(isSelected ? .addTransactionToggleSelectedText : .recordsNeutralIconTint)
				.frame(maxWidth: .infinity)
				.padding(.vertical, 8)
				.background(
					Capsule().fill(isSelected ? Color.recordsChipSelectedBackground : .clear)
				)
		}
		.disabled(isDisabled)
		.opacity(isDisabled ? 0.5 : 1)
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
