//
//  BalanceCard.swift
//  finance-test-ios
//

import SwiftUI

struct BalanceCard: View {
	let amount: Double

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text("BALANCE THIS MONTH")
				.font(.baseStyle(size: 12, weight: .bold))
				.foregroundStyle(.neutral60)

			AnimatedAmountText(amount: amount)
				.font(.baseStyle(size: 32, weight: .bold))
				.foregroundStyle(.brandPrimary)

			Text("Income - Expense")
				.font(.baseStyle(size: 13, weight: .regular))
				.foregroundStyle(.neutral60)

			HStack(spacing: 4) {
				Image(systemName: "arrow.up.right")
					.font(.baseStyle(size: 12, weight: .bold))
				Text("Healthy margin")
					.font(.baseStyle(size: 13, weight: .medium))
			}
			.foregroundStyle(.homeSuccess)
			.padding(.top, 2)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.cardStyle()
	}
}

#Preview {
	BalanceCard(amount: 2_100)
		.padding()
}
