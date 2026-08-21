//
//  CurrencyAvatarView.swift
//  finance-test-ios
//

import SwiftUI

/// Circular symbol/code badge shown next to a currency row, matching the Figma "User Currencies"
/// and "Select Currency" frames.
struct CurrencyAvatarView: View {
	let glyph: String
	let backgroundColor: Color
	let foregroundColor: Color
	let diameter: CGFloat

	init(
		currency: Currency.Response.CurrencyItem,
		backgroundColor: Color = .brandPrimary,
		foregroundColor: Color = .white,
		diameter: CGFloat = 44
	) {
		self.glyph = Self.resolveGlyph(for: currency)
		self.backgroundColor = backgroundColor
		self.foregroundColor = foregroundColor
		self.diameter = diameter
	}

	var body: some View {
		Circle()
			.fill(backgroundColor)
			.frame(width: diameter, height: diameter)
			.overlay {
				Text(glyph)
					.font(.baseStyle(size: diameter * 0.4, weight: .bold))
					.foregroundStyle(foregroundColor)
					.minimumScaleFactor(0.6)
					.lineLimit(1)
					.padding(4)
			}
	}

	/// Prefers the currency's symbol (`$`, `€`, `¥`); falls back to the first two letters of its
	/// code for currencies without a single-glyph symbol (e.g. `CHF` -> "Fr" isn't backend data,
	/// so a two-letter code prefix is the closest generic fallback).
	private static func resolveGlyph(for currency: Currency.Response.CurrencyItem) -> String {
		if let symbol = currency.symbol, !symbol.isEmpty {
			return symbol
		}
		return String((currency.code ?? "?").prefix(2))
	}
}

#Preview {
	HStack(spacing: 12) {
		CurrencyAvatarView(currency: .usd)
		CurrencyAvatarView(currency: Currency.Response.CurrencyItem.mocks[1])
		CurrencyAvatarView(currency: Currency.Response.CurrencyItem.mocks[3], backgroundColor: .neutral40, foregroundColor: .neutral90)
	}
	.padding()
}
