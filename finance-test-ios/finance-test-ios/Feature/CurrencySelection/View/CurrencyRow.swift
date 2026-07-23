//
//  CurrencyRow.swift
//  finance-test-ios
//

import SwiftUI

struct CurrencyRow: View {
	let currency: Currency
	let isSelected: Bool
	let onTap: () -> Void

	var body: some View {
		Button(action: onTap) {
			HStack(spacing: 12) {
				Text(currency.symbol)
					.font(.baseStyle(size: 16, weight: .bold))
					.foregroundStyle(isSelected ? .neutral10 : .neutral90)
					.frame(width: 24)

				Text("\(currency.code) - \(currency.name)")
					.font(.baseStyle(size: 15, weight: .medium))
					.foregroundStyle(isSelected ? .neutral10 : .neutral100)

				Spacer()

				if isSelected {
					Image(systemName: "checkmark.circle.fill")
						.foregroundStyle(.neutral10)
						.transition(.scale.combined(with: .opacity))
				}
			}
			.padding(.horizontal, 14)
			.padding(.vertical, 14)
			.background(
				RoundedRectangle(cornerRadius: 12)
					.fill(isSelected ? Color.brandSecondary : Color.clear)
			)
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
	}
}

#Preview {
	VStack(spacing: 8) {
		ForEach(Currency.mocks) { currency in
			CurrencyRow(currency: currency, isSelected: currency == .usd) {}
		}
	}
	.padding()
}
