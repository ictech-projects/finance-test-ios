//
//  FinanceAppShortcuts.swift
//  finance-test-ios
//

import AppIntents

/// Registers this app's Siri/Shortcuts entry points. Discovered automatically by the system once
/// the app has launched at least once - no Info.plist entry or capability needed.
struct FinanceAppShortcuts: AppShortcutsProvider {
	static var appShortcuts: [AppShortcut] {
		AppShortcut(
			intent: AddExpenseIntent(),
			phrases: [
				"Log an expense in \(.applicationName)",
				"Add an expense in \(.applicationName)",
				"Track an expense in \(.applicationName)",
				"Record an expense in \(.applicationName)"
			],
			shortTitle: "Log Expense",
			systemImageName: "creditcard.fill"
		)
	}
}
