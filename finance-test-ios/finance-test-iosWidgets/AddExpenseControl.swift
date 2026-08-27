//
//  AddExpenseControl.swift
//  finance-test-iosWidgets
//

import AppIntents
import SwiftUI
import WidgetKit

/// "Add Expense" control for Control Center (also available on the Lock Screen and as an Action
/// button assignment, which the system offers for any control for free).
///
/// `StaticControlConfiguration` because there is nothing for the user to configure — tapping it
/// always opens the same quick-add flow. Matching the "Log Expense" Shortcut's `creditcard.fill`
/// keeps the two entry points recognisably the same action.
struct AddExpenseControl: ControlWidget {
	static let kind = "com.indie.finance-test-ios.AddExpenseControl"

	var body: some ControlWidgetConfiguration {
		StaticControlConfiguration(kind: Self.kind) {
			ControlWidgetButton(action: OpenAddExpenseIntent()) {
				Label("Add Expense", systemImage: "creditcard.fill")
			}
		}
		.displayName("Add Expense")
		.description("Start logging a new expense in SpendWise.")
	}
}
