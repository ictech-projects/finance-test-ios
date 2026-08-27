//
//  OpenAddExpenseIntent.swift
//  finance-test-ios
//

import AppIntents

/// Opens the app on the quick-add expense sheet. This is what the Control Center control runs.
///
/// Not `AddExpenseIntent` (ticket 04): that one takes a required amount and category so Siri can
/// prompt for them, and a Control Center button has no way to ask for either — it fires with
/// whatever it was configured with. So the control hands the user the same flow in the app rather
/// than failing on a missing amount.
///
/// `openAppWhenRun` makes the system launch the app and run `perform()` in the *app's* process,
/// which is why this can talk to `AppIntentRouter.shared` directly instead of needing an App
/// Group to pass the request across.
struct OpenAddExpenseIntent: AppIntent {
	static var title: LocalizedStringResource = "Add Expense"
	static var description = IntentDescription("Open the app and start logging a new expense.")
	static var openAppWhenRun = true

	@MainActor
	func perform() async throws -> some IntentResult {
		AppIntentRouter.shared.request(.addExpense)
		return .result()
	}
}
