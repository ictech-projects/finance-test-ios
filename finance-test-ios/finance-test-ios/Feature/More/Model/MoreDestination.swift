//
//  MoreDestination.swift
//  finance-test-ios
//

import Foundation

/// The More screen's rows. `.currency` pushes the real `UserCurrenciesListView`; the rest still
/// push to `ComingSoonPlaceholderView`.
enum MoreDestination: Hashable, CaseIterable {
	case appearance
	case accounts
	case categories
	case currency

	var rowLabel: String {
		switch self {
		case .appearance: "Appearance Setting"
		case .accounts: "Accounts"
		case .categories: "Categories"
		case .currency: "Currency"
		}
	}

	var placeholderTitle: String {
		switch self {
		case .appearance: "Appearance"
		case .accounts: "Accounts"
		case .categories: "Categories"
		case .currency: "Currency"
		}
	}

	var iconName: String {
		switch self {
		case .appearance: "paintpalette.fill"
		case .accounts: "building.columns.fill"
		case .categories: "tag.fill"
		case .currency: "dollarsign.circle.fill"
		}
	}

	static let managementCases: [MoreDestination] = [.accounts, .categories, .currency]
}
