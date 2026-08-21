//
//  NetWorthCard.swift
//  finance-test-ios
//

import SwiftUI

struct NetWorthCard: View {
	let amount: Double

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			// Fixed white/near-white, not `.neutralX` — this text sits permanently on the colored
			// `.brandPrimary` fill below, which doesn't invert with the rest of the page in dark
			// mode, so the text shouldn't invert either.
			Text("NET WORTH")
				.font(.baseStyle(size: 12, weight: .bold))
				.foregroundStyle(.white.opacity(0.7))

			AnimatedAmountText(amount: amount)
				.font(.baseStyle(size: 32, weight: .bold))
				.foregroundStyle(.white)

			Text("Assets - Liabilities")
				.font(.baseStyle(size: 13, weight: .regular))
				.foregroundStyle(.white.opacity(0.7))

			HStack(spacing: 6) {
				Image(systemName: "creditcard.fill")
					.font(.baseStyle(size: 12, weight: .medium))
				Text("Total monitored assets")
					.font(.baseStyle(size: 13, weight: .medium))
			}
			.foregroundStyle(.white.opacity(0.85))
			.padding(.top, 2)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(16)
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(.brandPrimary)
		)
	}
}

#Preview {
	NetWorthCard(amount: 142_800)
		.padding()
}
