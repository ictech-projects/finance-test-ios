//
//  RecordsCatalog.swift
//  finance-test-ios
//

import SwiftUI

struct RecordsCategoryInfo: Equatable {
	let name: String
	let icon: ImageResource
	let iconBackground: Color
}

struct RecordsAccountInfo: Equatable {
	let name: String
	let icon: ImageResource
}

/// `TransactionRecord.Response.TransactionItem` only carries `category_id`/`account_id` — the
/// real `/transactions` endpoint doesn't join category or account data. Until dedicated
/// Category/Account data layers exist, this client-side lookup resolves the mock catalog ids
/// used by `Transaction.Response.TransactionItem.mocks` into display-ready name/icon/color.
///
/// Icons are custom assets exported from the Figma design (`Records/Icon` in the asset catalog),
/// not SF Symbols — the design uses bespoke glyphs (e.g. a camera for Freelance Income) that
/// don't correspond to standard system symbols.
enum RecordsCatalog {
	static let categories: [String: RecordsCategoryInfo] = [
		"01K3CT0000000000000000CT01": RecordsCategoryInfo(
			name: "Dining & Drinks", icon: .recordsDiningIcon, iconBackground: .recordsDiningIconBackground
		),
		"01K3CT0000000000000000CT02": RecordsCategoryInfo(
			name: "Freelance Income", icon: .recordsFreelanceIcon, iconBackground: .recordsChipSelectedBackground
		),
		"01K3CT0000000000000000CT03": RecordsCategoryInfo(
			name: "Transport", icon: .recordsTransportIcon, iconBackground: .recordsNeutralIconBackground
		),
		"01K3CT0000000000000000CT04": RecordsCategoryInfo(
			name: "Groceries", icon: .recordsGroceriesIcon, iconBackground: .recordsNeutralIconBackground
		),
		"01K3CT0000000000000000CT05": RecordsCategoryInfo(
			name: "Entertainment", icon: .recordsEntertainmentIcon, iconBackground: .recordsNeutralIconBackground
		)
	]

	static let accounts: [String: RecordsAccountInfo] = [
		"01K3AC0000000000000000AC01": RecordsAccountInfo(name: "Cash", icon: .recordsCashIcon),
		"01K3AC0000000000000000AC02": RecordsAccountInfo(name: "Main Bank", icon: .recordsMainbankIcon),
		"01K3AC0000000000000000AC03": RecordsAccountInfo(name: "Credit Card", icon: .recordsCreditcardIcon)
	]

	static let unknownCategory = RecordsCategoryInfo(
		name: "Uncategorized", icon: .recordsCategoryIcon, iconBackground: .recordsNeutralIconBackground
	)

	static let unknownAccount = RecordsAccountInfo(name: "Unknown Account", icon: .recordsAccountsIcon)
}
