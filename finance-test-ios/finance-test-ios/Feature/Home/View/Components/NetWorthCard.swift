//
//  NetWorthCard.swift
//  finance-test-ios
//

import SwiftUI

struct NetWorthCard: View {
	let amount: Double

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text("NET WORTH")
				.font(.baseStyle(size: 12, weight: .bold))
				.foregroundStyle(.neutral30)

			AnimatedAmountText(amount: amount)
				.font(.baseStyle(size: 32, weight: .bold))
				.foregroundStyle(.neutral10)

			Text("Assets - Liabilities")
				.font(.baseStyle(size: 13, weight: .regular))
				.foregroundStyle(.neutral30)

			HStack(spacing: 6) {
				Image(systemName: "creditcard.fill")
					.font(.baseStyle(size: 12, weight: .medium))
				Text("Total monitored assets")
					.font(.baseStyle(size: 13, weight: .medium))
			}
			.foregroundStyle(.neutral20)
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
