//
//  RecordsRowDisplay.swift
//  finance-test-ios
//

import SwiftUI

struct RecordsRowDisplay: Identifiable, Equatable {
	let id: String
	let categoryName: String
	let categoryIconName: String
	let categoryIconBackground: Color
	let description: String
	let accountName: String
	let accountIconName: String
	let amountLabel: String
	let isCredit: Bool
	let timeLabel: String
}

extension RecordsRowDisplay {
	static let mocks: [RecordsRowDisplay] = [
		RecordsRowDisplay(
			id: "preview-1", categoryName: "Dining & Drinks", categoryIconName: "fork.knife",
			categoryIconBackground: .recordsDiningIconBackground, description: "Lunch at the Bistro",
			accountName: "Cash", accountIconName: "banknote.fill",
			amountLabel: "-$42.50", isCredit: false, timeLabel: "12:45 PM"
		),
		RecordsRowDisplay(
			id: "preview-2", categoryName: "Freelance Income", categoryIconName: "briefcase.fill",
			categoryIconBackground: .recordsChipSelectedBackground, description: "UI Design Project",
			accountName: "Main Bank", accountIconName: "building.columns.fill",
			amountLabel: "+$1,200.00", isCredit: true, timeLabel: "09:15 AM"
		)
	]
}
