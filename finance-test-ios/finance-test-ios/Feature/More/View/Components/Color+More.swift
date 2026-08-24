//
//  Color+More.swift
//  finance-test-ios
//

import SwiftUI

extension Color {
	/// #24389C (light) / #2E47C7 (dark) — "More" heading + section header text.
	static let moreHeading = Color(
		light: Color(red: 0x24 / 255, green: 0x38 / 255, blue: 0x9C / 255),
		dark: Color(red: 0x2E / 255, green: 0x47 / 255, blue: 0xC7 / 255)
	)
	/// #F4F2FC (light) / #1F1E24 (dark) — profile card fill.
	static let moreProfileCardBackground = Color(
		light: Color(red: 0xF4 / 255, green: 0xF2 / 255, blue: 0xFC / 255),
		dark: Color(red: 0x1F / 255, green: 0x1E / 255, blue: 0x24 / 255)
	)
	/// #EFEDF6 (light) / #242329 (dark) — Appearance/Management section card fill.
	static let moreSectionCardBackground = Color(
		light: Color(red: 0xEF / 255, green: 0xED / 255, blue: 0xF6 / 255),
		dark: Color(red: 0x24 / 255, green: 0x23 / 255, blue: 0x29 / 255)
	)
	/// #C5C5D4 (light) / #72727A (dark) — base for the profile card border (`.opacity(0.3)`) and
	/// row separators (`.opacity(0.2)`).
	static let moreHairline = Color(
		light: Color(red: 0xC5 / 255, green: 0xC5 / 255, blue: 0xD4 / 255),
		dark: Color(red: 0x72 / 255, green: 0x72 / 255, blue: 0x7A / 255)
	)
	/// #DCDEF7 (light) / #2B2C3D (dark) — "Edit Profile" pill fill.
	static let moreEditProfileBackground = Color(
		light: Color(red: 0xDC / 255, green: 0xDE / 255, blue: 0xF7 / 255),
		dark: Color(red: 0x2B / 255, green: 0x2C / 255, blue: 0x3D / 255)
	)
	/// #5E6177 (light) / #B4B9D9 (dark) — "Edit Profile" pill text.
	static let moreEditProfileText = Color(
		light: Color(red: 0x5E / 255, green: 0x61 / 255, blue: 0x77 / 255),
		dark: Color(red: 0xB4 / 255, green: 0xB9 / 255, blue: 0xD9 / 255)
	)
	/// #454652 (light) / #BDBFD9 (dark) — profile card email text.
	static let moreProfileEmailText = Color(
		light: Color(red: 0x45 / 255, green: 0x46 / 255, blue: 0x52 / 255),
		dark: Color(red: 0xBD / 255, green: 0xBF / 255, blue: 0xD9 / 255)
	)
}

extension ShapeStyle where Self == Color {
	static var moreHeading: Color { .moreHeading }
	static var moreProfileCardBackground: Color { .moreProfileCardBackground }
	static var moreSectionCardBackground: Color { .moreSectionCardBackground }
	static var moreHairline: Color { .moreHairline }
	static var moreEditProfileBackground: Color { .moreEditProfileBackground }
	static var moreEditProfileText: Color { .moreEditProfileText }
	static var moreProfileEmailText: Color { .moreProfileEmailText }
}
