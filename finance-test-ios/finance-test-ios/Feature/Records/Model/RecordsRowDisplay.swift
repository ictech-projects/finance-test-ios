//
//  RecordsRowDisplay.swift
//  finance-test-ios
//

import SwiftUI

struct RecordsRowDisplay: Identifiable, Equatable {
	let id: String
	let categoryName: String
	let categoryIcon: ImageResource
	let categoryIconTint: Color
	let categoryIconBackground: Color
	let description: String
	let accountName: String
	let accountIcon: ImageResource
	let amountLabel: String
	let isCredit: Bool
	let timeLabel: String
}

extension RecordsRowDisplay {
	static let mocks: [RecordsRowDisplay] = [
		RecordsRowDisplay(
			id: "preview-1", categoryName: "Dining & Drinks", categoryIcon: .recordsDiningIcon,
			categoryIconTint: .recordsDiningIconTint, categoryIconBackground: .recordsDiningIconBackground,
			description: "Lunch at the Bistro",
			accountName: "Cash", accountIcon: .recordsCashIcon,
			amountLabel: "-$42.50", isCredit: false, timeLabel: "12:45 PM"
		),
		RecordsRowDisplay(
			id: "preview-2", categoryName: "Freelance Income", categoryIcon: .recordsFreelanceIcon,
			categoryIconTint: .brandPrimary, categoryIconBackground: .recordsChipSelectedBackground,
			description: "UI Design Project",
			accountName: "Main Bank", accountIcon: .recordsMainbankIcon,
			amountLabel: "+$1,200.00", isCredit: true, timeLabel: "09:15 AM"
		)
	]
}
