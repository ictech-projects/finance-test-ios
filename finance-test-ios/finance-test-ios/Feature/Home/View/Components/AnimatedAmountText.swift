//
//  AnimatedAmountText.swift
//  finance-test-ios
//

import SwiftUI

struct AnimatedAmountText: View {
	let amount: Double

	@State private var displayedAmount: Double = 0

	var body: some View {
		Text(displayedAmount.currencyWholeFormatted())
			.contentTransition(.numericText())
			.animation(.easeOut(duration: 1.0), value: displayedAmount)
			.onAppear {
				displayedAmount = amount
			}
	}
}

#Preview {
	AnimatedAmountText(amount: 142_800)
		.font(.baseStyle(size: 32, weight: .bold))
		.padding()
}
