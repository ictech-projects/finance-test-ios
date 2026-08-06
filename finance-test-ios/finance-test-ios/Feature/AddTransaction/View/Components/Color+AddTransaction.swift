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
	static let addTransactionToggleSelectedText = Color(red: 0x5E / 255, green: 0x61 / 255, blue: 0x77 / 255)
	static let addTransactionMutedLabel = Color(red: 0x75 / 255, green: 0x76 / 255, blue: 0x84 / 255)
	static let addTransactionValueText = Color(red: 0x1A / 255, green: 0x1B / 255, blue: 0x22 / 255)
	static let addTransactionFabBackground = Color(red: 0x3F / 255, green: 0x51 / 255, blue: 0xB5 / 255)
	static let addTransactionFabText = Color(red: 0xCA / 255, green: 0xCF / 255, blue: 0xFF / 255)
}

extension ShapeStyle where Self == Color {
	static var addTransactionToggleSelectedText: Color { .addTransactionToggleSelectedText }
	static var addTransactionMutedLabel: Color { .addTransactionMutedLabel }
	static var addTransactionValueText: Color { .addTransactionValueText }
	static var addTransactionFabBackground: Color { .addTransactionFabBackground }
	static var addTransactionFabText: Color { .addTransactionFabText }
}
