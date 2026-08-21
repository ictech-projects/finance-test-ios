//
//  AppearanceMode.swift
//  finance-test-ios
//

import SwiftUI

/// The user's chosen app-wide theme. `.system` defers to the OS setting — `colorScheme` returns
/// `nil` for it since `.preferredColorScheme(nil)` is how SwiftUI expresses "follow the system."
enum AppearanceMode: String, CaseIterable, Identifiable {
	case system
	case light
	case dark

	var id: String { rawValue }

	var label: String {
		switch self {
		case .system: "System"
		case .light: "Light"
		case .dark: "Dark"
		}
	}

	var colorScheme: ColorScheme? {
		switch self {
		case .system: nil
		case .light: .light
		case .dark: .dark
		}
	}
}
