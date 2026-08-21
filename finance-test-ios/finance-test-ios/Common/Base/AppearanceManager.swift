//
//  AppearanceManager.swift
//  finance-test-ios
//

import Combine
import Foundation

/// Single source of truth for the app's theme choice — injected once at the app root via
/// `.environmentObject` rather than threaded through individual ViewModel initializers, since it's
/// shared, app-wide state rather than anything a particular feature owns.
@MainActor
final class AppearanceManager: ObservableObject {
	private static let userDefaultsKey = "appearanceMode"

	@Published var mode: AppearanceMode {
		didSet {
			UserDefaults.standard.set(mode.rawValue, forKey: Self.userDefaultsKey)
		}
	}

	init(userDefaults: UserDefaults = .standard) {
		let storedRawValue = userDefaults.string(forKey: Self.userDefaultsKey)
		self.mode = storedRawValue.flatMap(AppearanceMode.init(rawValue:)) ?? .system
	}
}
