//
//  Color+Home.swift
//  finance-test-ios
//

import SwiftUI

extension Color {
	static let homeSuccess = Color(
		light: Color(red: 0x45 / 255, green: 0x7B / 255, blue: 0x3B / 255),
		dark: Color(red: 0x6B / 255, green: 0xBF / 255, blue: 0x5C / 255)
	)
	static let homeDanger = Color(
		light: Color(red: 0xC2 / 255, green: 0x3F / 255, blue: 0x38 / 255),
		dark: Color(red: 0xCC / 255, green: 0x42 / 255, blue: 0x3B / 255)
	)
	static let homeOrange = Color(
		light: Color(red: 0xDD / 255, green: 0x74 / 255, blue: 0x2D / 255),
		dark: Color(red: 0xE0 / 255, green: 0x76 / 255, blue: 0x2E / 255)
	)
	static let homeAccentBlue = Color(
		light: Color(red: 0x47 / 255, green: 0x54 / 255, blue: 0xB3 / 255),
		dark: Color(red: 0x4F / 255, green: 0x5D / 255, blue: 0xC7 / 255)
	)
}

extension ShapeStyle where Self == Color {
	static var homeSuccess: Color { .homeSuccess }
	static var homeDanger: Color { .homeDanger }
	static var homeOrange: Color { .homeOrange }
	static var homeAccentBlue: Color { .homeAccentBlue }
}
