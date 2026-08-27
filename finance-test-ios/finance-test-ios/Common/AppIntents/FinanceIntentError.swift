//
//  FinanceIntentError.swift
//  finance-test-ios
//

import Foundation

/// Shared error type for this app's App Intents (Siri/Shortcuts) - `localizedStringResource` is
/// what Siri speaks and the Shortcuts app shows when an intent throws.
enum FinanceIntentError: Error, CustomLocalizedStringResourceConvertible, Equatable {
	case notLoggedIn
	case sessionExpired
	case invalidAmount
	case noAccountAvailable
	case noCategoryAvailable
	case categoryNotFound
	case requestFailed(message: String)

	var localizedStringResource: LocalizedStringResource {
		switch self {
		case .notLoggedIn:
			"Please open the app and log in first."
		case .sessionExpired:
			"Your session has expired. Please open the app and log in again."
		case .invalidAmount:
			"Enter an amount greater than zero."
		case .noAccountAvailable:
			"Add an account in the app before logging an expense."
		case .noCategoryAvailable:
			"Add an expense category in the app before logging an expense."
		case .categoryNotFound:
			"That category no longer exists. Please pick another one."
		case .requestFailed(let message):
			"\(message)"
		}
	}

	/// Maps a repository failure into the right case - a 401 gets the friendlier "log in again"
	/// case, distinct from `.notLoggedIn` (no token on this device at all, checked before any
	/// network call); everything else surfaces the backend's own message where available,
	/// matching `ProfileViewModel`/`AccountFormViewModel`'s existing error mapping.
	static func from(_ error: Error) -> FinanceIntentError {
		guard let errorResponse = error as? ErrorResponse else {
			return .requestFailed(message: String(localized: "Something went wrong. Please try again."))
		}
		if errorResponse.statusCode == 401 {
			return .sessionExpired
		}
		return .requestFailed(message: errorResponse.message ?? String(localized: "Something went wrong. Please try again."))
	}
}
