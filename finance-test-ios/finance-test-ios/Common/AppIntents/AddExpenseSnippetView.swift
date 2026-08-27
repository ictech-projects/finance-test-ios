//
//  AddExpenseSnippetView.swift
//  finance-test-ios
//

import SwiftUI

/// The card Siri/Shortcuts shows after `AddExpenseIntent` creates a transaction.
///
/// Deliberately mirrors `RecordsRow`'s anatomy (48pt tinted icon, 12pt radius, 17pt padding,
/// 16/14/11 type ramp) so the result reads as this app's content rather than a generic card.
///
/// Per Apple's guidance the snippet complements the spoken response instead of repeating it:
/// Siri already says "Logged your Food & Drink expense of $25.00", so this shows the *record* —
/// category, note, account, amount — and never a "logged!" banner.
struct AddExpenseSnippetView: View {
	let result: AddExpenseResult

	private var tint: Color {
		result.categoryColorHex.flatMap { Color(hex: $0) } ?? .brandPrimary
	}

	var body: some View {
		HStack(alignment: .top, spacing: 16) {
			Image(systemName: result.categoryIcon)
				.font(.system(size: 20, weight: .medium))
				.foregroundStyle(tint)
				.frame(width: 48, height: 48)
				.background(Circle().fill(tint.opacity(0.15)))

			VStack(alignment: .leading, spacing: 0) {
				Text(result.categoryName)
					.font(.baseStyle(size: 16, weight: .bold))
					.foregroundStyle(.neutral100)

				// Omitted entirely when the caller gave no merchant/note — the card then sits at
				// two lines rather than showing an empty row.
				if let note = result.note {
					Text(note)
						.font(.baseStyle(size: 14, weight: .regular))
						.foregroundStyle(.neutral90)
				}

				HStack(spacing: 4) {
					Image(systemName: "creditcard")
						.font(.system(size: 11, weight: .medium))
					Text(result.accountName)
						.font(.baseStyle(size: 11, weight: .medium))
				}
				.foregroundStyle(.neutral70)
				.padding(.top, 2)
			}

			Spacer(minLength: 8)

			VStack(alignment: .trailing, spacing: 6) {
				Text(result.amount.expenseAmountLabel)
					.font(.baseStyle(size: 16, weight: .bold))
					.foregroundStyle(.dangerMain)

				// The intent always stamps the transaction with the current date, so this is
				// accurate by construction — it has no date parameter to vary.
				Text("Today")
					.font(.baseStyle(size: 11, weight: .medium))
					.foregroundStyle(.neutral70)
			}
		}
		.padding(17)
		.background(RoundedRectangle(cornerRadius: 12).fill(Color.recordsCardBackground))
		.overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.recordsCardBorder, lineWidth: 1))
	}
}

private extension Double {
	/// Matches `RecordsRow`'s convention of showing an expense as a negative amount.
	var expenseAmountLabel: String {
		"-\(self.currencyFormatted())"
	}
}

#Preview("With note") {
	AddExpenseSnippetView(
		result: AddExpenseResult(
			amount: 25,
			categoryName: "Food & Drink",
			categoryIcon: "fork.knife",
			categoryColorHex: "#E53935",
			accountName: "commonwealth",
			note: "Lunch at the bistro"
		)
	)
	.padding()
}

#Preview("No note") {
	AddExpenseSnippetView(
		result: AddExpenseResult(
			amount: 12.5,
			categoryName: "Transport",
			categoryIcon: "bus",
			categoryColorHex: "#8E24AA",
			accountName: "commonwealth",
			note: nil
		)
	)
	.padding()
}
