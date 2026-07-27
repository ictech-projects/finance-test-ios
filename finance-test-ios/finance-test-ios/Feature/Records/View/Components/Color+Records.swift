//
//  Color+Records.swift
//  finance-test-ios
//

import SwiftUI

/// Pastel surface tones from the Records Figma design with no equivalent in the
/// existing Neutral/Brand palette (which is pure gray / saturated brand colors only).
extension Color {
	static let recordsCardBackground = Color(red: 0xF4 / 255, green: 0xF2 / 255, blue: 0xFC / 255)
	static let recordsCardBorder = Color(red: 0xC5 / 255, green: 0xC5 / 255, blue: 0xD4 / 255)
	static let recordsChipSelectedBackground = Color(red: 0xDC / 255, green: 0xDE / 255, blue: 0xF7 / 255)
	static let recordsDiningIconBackground = Color(red: 0xFF / 255, green: 0xDA / 255, blue: 0xD6 / 255)
	static let recordsNeutralIconBackground = Color(red: 0xE3 / 255, green: 0xE1 / 255, blue: 0xEA / 255)
}

extension ShapeStyle where Self == Color {
	static var recordsCardBackground: Color { .recordsCardBackground }
	static var recordsCardBorder: Color { .recordsCardBorder }
	static var recordsChipSelectedBackground: Color { .recordsChipSelectedBackground }
	static var recordsDiningIconBackground: Color { .recordsDiningIconBackground }
	static var recordsNeutralIconBackground: Color { .recordsNeutralIconBackground }
}
