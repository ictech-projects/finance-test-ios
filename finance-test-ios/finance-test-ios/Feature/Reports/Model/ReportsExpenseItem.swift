//
//  ReportsExpenseItem.swift
//  finance-test-ios
//

import SwiftUI

struct ReportsExpenseItem: Identifiable {
	let id = UUID()
	let title: String
	let subtitle: String
	let amount: Double
	let iconSystemName: String
	let iconBackground: Color
	let iconForeground: Color
}
