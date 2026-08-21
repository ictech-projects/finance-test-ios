//
//  Color+AddTransaction.swift
//  finance-test-ios
//

import SwiftUI

/// Exact colors from the Add Transaction Figma design with no equivalent in the existing
/// Neutral/Brand palette. Several other tones this screen uses (card background/border, the
/// toggle's selected pill, the keypad container tint) already exist as `.recordsCardBackground`,
/// `.recordsCardBorder`, `.recordsChipSelectedBackground`, and `.recordsNeutralIconBackground` —
/// reused directly rather than redefined here.
extension Color {
	static let addTransactionToggleSelectedText = Color(
		light: Color(red: 0x5E / 255, green: 0x61 / 255, blue: 0x77 / 255),
		dark: Color(red: 0xB4 / 255, green: 0xB9 / 255, blue: 0xD9 / 255)
	)
	static let addTransactionMutedLabel = Color(
		light: Color(red: 0x75 / 255, green: 0x76 / 255, blue: 0x84 / 255),
		dark: Color(red: 0x9E / 255, green: 0x9F / 255, blue: 0xAD / 255)
	)
	static let addTransactionValueText = Color(
		light: Color(red: 0x1A / 255, green: 0x1B / 255, blue: 0x22 / 255),
		dark: Color(red: 0xE7 / 255, green: 0xE8 / 255, blue: 0xF0 / 255)
	)
	static let addTransactionFabBackground = Color(
		light: Color(red: 0x3F / 255, green: 0x51 / 255, blue: 0xB5 / 255),
		dark: Color(red: 0x45 / 255, green: 0x59 / 255, blue: 0xC7 / 255)
	)
	/// Already a light, accent-appropriate text color sitting on the FAB's own colored (non-neutral)
	/// background, not the app's neutral surfaces — kept fixed across appearances since the FAB is
	/// its own self-contained contrast pair, independent of the system light/dark setting.
	static let addTransactionFabText = Color(red: 0xCA / 255, green: 0xCF / 255, blue: 0xFF / 255)
}

extension ShapeStyle where Self == Color {
	static var addTransactionToggleSelectedText: Color { .addTransactionToggleSelectedText }
	static var addTransactionMutedLabel: Color { .addTransactionMutedLabel }
	static var addTransactionValueText: Color { .addTransactionValueText }
	static var addTransactionFabBackground: Color { .addTransactionFabBackground }
	static var addTransactionFabText: Color { .addTransactionFabText }
}
