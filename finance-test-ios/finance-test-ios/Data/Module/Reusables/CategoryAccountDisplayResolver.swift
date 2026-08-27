//
//  CategoryAccountDisplayResolver.swift
//  finance-test-ios
//

import SwiftUI

/// Resolves a transaction's `category_id`/`account_id` into display-ready name/icon/color, given
/// the categories/accounts already fetched alongside it. Replaces `RecordsCatalog`'s old
/// hardcoded-mock-id lookup now that real Category/Account data layers exist — used by both
/// `RecordsViewModel` and `HomeViewModel`. Holds no external/global state, only the lookup tables
/// built once from whatever arrays the caller passes in.
///
/// Categories must be the user's own (`Sync.Response.UserCategoryItem`, via
/// `UserCategoryRepository`), **not** the global `GET /categories` catalog: a transaction's
/// `category_id` references a user category, so keying this lookup by global ids silently
/// resolves everything to "Uncategorized".
struct CategoryAccountDisplayResolver {

	struct CategoryDisplay {
		let name: String
		let icon: String
		let iconTint: Color
		let iconBackground: Color
	}

	struct AccountDisplay {
		let name: String
		let icon: String
	}

	private static let uncategorizedName = "Uncategorized"
	private static let uncategorizedIcon = "questionmark.circle"
	private static let unknownAccountName = "Unknown Account"
	private static let unknownAccountIcon = "questionmark.circle"

	private let categoriesById: [String: Sync.Response.UserCategoryItem]
	private let accountsById: [String: Account.Response.AccountItem]

	init(categories: [Sync.Response.UserCategoryItem], accounts: [Account.Response.AccountItem]) {
		categoriesById = Dictionary(
			categories.compactMap { category in category.id.map { ($0, category) } },
			uniquingKeysWith: { first, _ in first }
		)
		accountsById = Dictionary(
			accounts.compactMap { account in account.id.map { ($0, account) } },
			uniquingKeysWith: { first, _ in first }
		)
	}

	func category(for id: String?) -> CategoryDisplay {
		guard let id, let category = categoriesById[id] else {
			return CategoryDisplay(
				name: Self.uncategorizedName, icon: Self.uncategorizedIcon,
				iconTint: .recordsNeutralIconTint, iconBackground: .recordsNeutralIconBackground
			)
		}

		let tint = category.color.flatMap { Color(hex: $0) } ?? .recordsNeutralIconTint
		return CategoryDisplay(
			name: category.name ?? Self.uncategorizedName,
			icon: category.icon ?? Self.uncategorizedIcon,
			iconTint: tint,
			iconBackground: tint.opacity(0.15)
		)
	}

	func account(for id: String?) -> AccountDisplay {
		guard let id, let account = accountsById[id] else {
			return AccountDisplay(name: Self.unknownAccountName, icon: Self.unknownAccountIcon)
		}

		return AccountDisplay(name: account.name ?? Self.unknownAccountName, icon: Self.icon(forAccountType: account.type))
	}

	private static func icon(forAccountType type: String?) -> String {
		switch type {
		case "cash": "banknote"
		case "bank_account": "building.columns"
		case "credit_card": "creditcard"
		case "savings": "banknote.fill"
		default: "wallet.pass"
		}
	}
}
