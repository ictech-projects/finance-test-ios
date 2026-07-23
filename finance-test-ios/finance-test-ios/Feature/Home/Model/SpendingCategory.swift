//
//  SpendingCategory.swift
//  finance-test-ios
//

import SwiftUI

struct SpendingCategory: Identifiable {
	let id = UUID()
	let name: String
	var percent: Double
	let color: Color
}

extension SpendingCategory {
	static let mocks: [SpendingCategory] = [
		SpendingCategory(name: "Housing", percent: 0.40, color: .brandPrimary),
		SpendingCategory(name: "Groceries", percent: 0.25, color: .successMain),
		SpendingCategory(name: "Lifestyle", percent: 0.15, color: .orange),
		SpendingCategory(name: "Others", percent: 0.20, color: .neutral40)
	]
}
