//
//  ReportsTopExpenseDisplay.swift
//  finance-test-ios
//

import SwiftUI

struct ReportsTopExpenseDisplay: Identifiable, Equatable {
	let id: String
	let description: String
	let categoryName: String
	let dateLabel: String
	let amountLabel: String
	let icon: String
	let iconTint: Color
	let iconBackground: Color
}

extension ReportsTopExpenseDisplay {
	static let mocks: [ReportsTopExpenseDisplay] = [
		ReportsTopExpenseDisplay(
			id: "preview-1", description: "Rent payment", categoryName: "Housing",
			dateLabel: "Sept 1", amountLabel: "-$1,800.00",
			icon: "house.fill", iconTint: .white, iconBackground: .brandPrimary
		),
		ReportsTopExpenseDisplay(
			id: "preview-2", description: "Whole Foods", categoryName: "Groceries",
			dateLabel: "Sept 12", amountLabel: "-$342.15",
			icon: "cart.fill", iconTint: .recordsNeutralIconTint, iconBackground: .recordsNeutralIconBackground
		)
	]
}
