//
//  TotalOwedCard.swift
//  finance-test-ios
//

import SwiftUI

struct TotalOwedCard: View {
	let totalOwed: Double
	let limit: Double
	let ratio: Double

	@State private var animatedRatio: Double = 0

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack(spacing: 12) {
				Image(systemName: "building.columns.fill")
					.font(.baseStyle(size: 14, weight: .bold))
					.foregroundStyle(.orange)
					.frame(width: 32, height: 32)
					.background(RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.15)))

				VStack(alignment: .leading, spacing: 2) {
					Text("Total Owed")
						.font(.baseStyle(size: 14, weight: .medium))
						.foregroundStyle(.neutral90)

					AnimatedAmountText(amount: totalOwed)
						.font(.baseStyle(size: 16, weight: .bold))
						.foregroundStyle(.neutral100)
				}

				Spacer()
			}

			GeometryReader { proxy in
				ZStack(alignment: .leading) {
					Capsule()
						.fill(.neutral20)

					Capsule()
						.fill(.orange)
						.frame(width: proxy.size.width * animatedRatio)
				}
			}
			.frame(height: 6)
			.onAppear {
				withAnimation(.easeOut(duration: 0.8)) {
					animatedRatio = ratio
				}
			}

			HStack {
				Text("\(Int(ratio * 100))% of limit")
					.font(.baseStyle(size: 12, weight: .regular))
					.foregroundStyle(.neutral60)

				Spacer()

				Text("$\(Int(limit / 1_000))k Limit")
					.font(.baseStyle(size: 12, weight: .regular))
					.foregroundStyle(.neutral60)
			}
		}
		.frame(maxWidth: .infinity)
		.cardStyle()
	}
}

#Preview {
	TotalOwedCard(totalOwed: 12_500, limit: 28_000, ratio: 0.45)
		.padding()
}
