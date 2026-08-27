//
//  FinanceWidgetBundle.swift
//  finance-test-iosWidgets
//

import SwiftUI
import WidgetKit

/// Entry point for the app's widget extension. Currently hosts the Control Center control only;
/// Home Screen and Lock Screen widgets (tickets 02/03) belong in this same bundle.
@main
struct FinanceWidgetBundle: WidgetBundle {
	var body: some Widget {
		AddExpenseControl()
	}
}
