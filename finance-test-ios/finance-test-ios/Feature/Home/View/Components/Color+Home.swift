//
//  Color+Home.swift
//  finance-test-ios
//

import SwiftUI

extension Color {
	static let homeSuccess = Color(red: 0x45 / 255, green: 0x7B / 255, blue: 0x3B / 255)
	static let homeDanger = Color(red: 0xC2 / 255, green: 0x3F / 255, blue: 0x38 / 255)
	static let homeOrange = Color(red: 0xDD / 255, green: 0x74 / 255, blue: 0x2D / 255)
	static let homeAccentBlue = Color(red: 0x47 / 255, green: 0x54 / 255, blue: 0xB3 / 255)
}

extension ShapeStyle where Self == Color {
	static var homeSuccess: Color { .homeSuccess }
	static var homeDanger: Color { .homeDanger }
	static var homeOrange: Color { .homeOrange }
	static var homeAccentBlue: Color { .homeAccentBlue }
}
