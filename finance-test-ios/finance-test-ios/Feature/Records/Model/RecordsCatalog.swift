//
//  RecordsCatalog.swift
//  finance-test-ios
//

import SwiftUI

struct RecordsCategoryInfo: Equatable {
	let name: String
	let iconName: String
	let iconBackground: Color
}

struct RecordsAccountInfo: Equatable {
	let name: String
	let iconName: String
}

/// `TransactionRecord.Response.TransactionItem` only carries `category_id`/`account_id` — the
/// real `/transactions` endpoint doesn't join category or account data. Until dedicated
/// Category/Account data layers exist, this client-side lookup resolves the mock catalog ids
/// used by `Transaction.Response.TransactionItem.mocks` into display-ready name/icon/color.
enum RecordsCatalog {
	static let categories: [String: RecordsCategoryInfo] = [
		"01K3CT0000000000000000CT01": RecordsCategoryInfo(
			name: "Dining & Drinks", iconName: "fork.knife", iconBackground: .recordsDiningIconBackground
		),
		"01K3CT0000000000000000CT02": RecordsCategoryInfo(
			name: "Freelance Income", iconName: "camera.fill", iconBackground: .recordsChipSelectedBackground
		),
		"01K3CT0000000000000000CT03": RecordsCategoryInfo(
			name: "Transport", iconName: "car.fill", iconBackground: .recordsNeutralIconBackground
		),
		"01K3CT0000000000000000CT04": RecordsCategoryInfo(
			name: "Groceries", iconName: "bag.fill", iconBackground: .recordsNeutralIconBackground
		),
		"01K3CT0000000000000000CT05": RecordsCategoryInfo(
			name: "Entertainment", iconName: "play.rectangle.fill", iconBackground: .recordsNeutralIconBackground
		)
	]

	static let accounts: [String: RecordsAccountInfo] = [
		"01K3AC0000000000000000AC01": RecordsAccountInfo(name: "Cash", iconName: "banknote.fill"),
		"01K3AC0000000000000000AC02": RecordsAccountInfo(name: "Main Bank", iconName: "building.columns.fill"),
		"01K3AC0000000000000000AC03": RecordsAccountInfo(name: "Credit Card", iconName: "creditcard.fill")
	]

	static let unknownCategory = RecordsCategoryInfo(
		name: "Uncategorized", iconName: "questionmark.circle.fill", iconBackground: .recordsNeutralIconBackground
	)

	static let unknownAccount = RecordsAccountInfo(name: "Unknown Account", iconName: "questionmark.circle.fill")
}
