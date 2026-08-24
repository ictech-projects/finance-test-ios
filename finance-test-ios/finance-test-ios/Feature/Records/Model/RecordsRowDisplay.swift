//
//  RecordsRowDisplay.swift
//  finance-test-ios
//

import SwiftUI

struct RecordsRowDisplay: Identifiable, Equatable {
	let id: String
	let categoryName: String
	/// SF Symbol name — real categories carry their own `icon` field from the backend (see
	/// `CategoryAccountDisplayResolver`), so this is no longer a custom asset-catalog reference.
	let categoryIcon: String
	let categoryIconTint: Color
	let categoryIconBackground: Color
	let description: String
	let accountName: String
	/// SF Symbol name, derived from the account's `type` (see `CategoryAccountDisplayResolver`).
	let accountIcon: String
	let amountLabel: String
	let isCredit: Bool
	let timeLabel: String
}

extension RecordsRowDisplay {
	static let mocks: [RecordsRowDisplay] = [
		RecordsRowDisplay(
			id: "preview-1", categoryName: "Dining & Drinks", categoryIcon: "fork.knife",
			categoryIconTint: .recordsDiningIconTint, categoryIconBackground: .recordsDiningIconBackground,
			description: "Lunch at the Bistro",
			accountName: "Cash", accountIcon: "banknote",
			amountLabel: "-$42.50", isCredit: false, timeLabel: "12:45 PM"
		),
		RecordsRowDisplay(
			id: "preview-2", categoryName: "Freelance Income", categoryIcon: "camera",
			categoryIconTint: .brandPrimary, categoryIconBackground: .recordsChipSelectedBackground,
			description: "UI Design Project",
			accountName: "Main Bank", accountIcon: "building.columns",
			amountLabel: "+$1,200.00", isCredit: true, timeLabel: "09:15 AM"
		)
	]
}
