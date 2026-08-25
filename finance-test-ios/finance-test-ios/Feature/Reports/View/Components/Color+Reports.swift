//
//  Color+Reports.swift
//  finance-test-ios
//

import SwiftUI

/// Exact colors from the Reports Figma design with no equivalent in the existing Neutral/Brand
/// palette. Card background/border, the donut's light ring, body/headline text, and the brand
/// action tint already exist as `.recordsCardBackground`, `.recordsCardBorder`,
/// `.recordsChipSelectedBackground`, `.recordsNeutralIconTint`, `.addTransactionValueText`, and
/// `.addTransactionFabBackground` — reused directly rather than redefined here.
extension Color {
	static let reportsAccentText = Color(red: 0x24 / 255, green: 0x38 / 255, blue: 0x9C / 255)
	static let reportsUtilitiesOrange = Color(red: 0xED / 255, green: 0x6C / 255, blue: 0x02 / 255)
	static let reportsPositiveGreen = Color(red: 0x2E / 255, green: 0x7D / 255, blue: 0x32 / 255)
	static let reportsNegativeRed = Color(red: 0xD3 / 255, green: 0x2F / 255, blue: 0x2F / 255)
	static let reportsSegmentedTrackBackground = Color(red: 0xE9 / 255, green: 0xE7 / 255, blue: 0xF0 / 255)
	static let reportsExpenseRowBackground = Color(red: 0xEF / 255, green: 0xED / 255, blue: 0xF6 / 255)
}

extension ShapeStyle where Self == Color {
	static var reportsAccentText: Color { .reportsAccentText }
	static var reportsUtilitiesOrange: Color { .reportsUtilitiesOrange }
	static var reportsPositiveGreen: Color { .reportsPositiveGreen }
	static var reportsNegativeRed: Color { .reportsNegativeRed }
	static var reportsSegmentedTrackBackground: Color { .reportsSegmentedTrackBackground }
	static var reportsExpenseRowBackground: Color { .reportsExpenseRowBackground }
}
