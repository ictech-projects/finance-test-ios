//
//  AppIntentRouter.swift
//  finance-test-ios
//

import Combine
import Foundation

/// One-shot hand-off from an App Intent to the running app's UI.
///
/// Lives in the shared folder because the intents that publish to it (`OpenAddExpenseIntent`)
/// are compiled into both the app and the widget extension. Deliberately dependency-free — the
/// extension links none of the app's networking/repository code, so anything reachable from here
/// has to stay Foundation-only.
///
/// Requests are *pending* rather than events: an intent can fire before the UI that consumes it
/// exists (a control tap cold-launches the app, and `RecordsView` isn't built until its tab is
/// selected), so the request is held until a consumer calls `clear()`.
@MainActor
final class AppIntentRouter: ObservableObject {
	enum Request: Equatable {
		/// Open the quick-add expense sheet.
		case addExpense
	}

	static let shared = AppIntentRouter()

	@Published private(set) var pendingRequest: Request?

	private init() {}

	func request(_ request: Request) {
		pendingRequest = request
	}

	/// Called by whichever view has acted on the request. Clearing is what lets an identical
	/// second tap register as a new request rather than a no-op `@Published` write.
	func clear() {
		pendingRequest = nil
	}
}
