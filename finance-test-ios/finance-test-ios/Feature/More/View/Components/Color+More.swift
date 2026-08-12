//
//  Color+More.swift
//  finance-test-ios
//

import SwiftUI

extension Color {
	/// #24389C — "More" heading + section header text.
	static let moreHeading = Color(red: 0x24 / 255, green: 0x38 / 255, blue: 0x9C / 255)
	/// #F4F2FC — profile card fill.
	static let moreProfileCardBackground = Color(red: 0xF4 / 255, green: 0xF2 / 255, blue: 0xFC / 255)
	/// #EFEDF6 — Appearance/Management section card fill.
	static let moreSectionCardBackground = Color(red: 0xEF / 255, green: 0xED / 255, blue: 0xF6 / 255)
	/// #C5C5D4 — base for the profile card border (`.opacity(0.3)`) and row separators (`.opacity(0.2)`).
	static let moreHairline = Color(red: 0xC5 / 255, green: 0xC5 / 255, blue: 0xD4 / 255)
	/// #DCDEF7 — "Edit Profile" pill fill.
	static let moreEditProfileBackground = Color(red: 0xDC / 255, green: 0xDE / 255, blue: 0xF7 / 255)
	/// #5E6177 — "Edit Profile" pill text.
	static let moreEditProfileText = Color(red: 0x5E / 255, green: 0x61 / 255, blue: 0x77 / 255)
	/// #454652 — profile card email text.
	static let moreProfileEmailText = Color(red: 0x45 / 255, green: 0x46 / 255, blue: 0x52 / 255)
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
