//
//  CategoryIconResolver.swift
//  finance-test-ios
//

import Foundation

/// Turns a category's stored `icon` into a usable SF Symbol name.
///
/// The `icon` field carries **two different vocabularies**:
/// - Backend-seeded categories store Lucide names (`"utensils"`, `"graduation-cap"`,
///   `"rotate-ccw"`) — none of which are SF Symbols, so `Image(systemName:)` renders nothing.
/// - Categories created in-app store SF Symbols already, from
///   `AddCategoryViewModel.iconOptions` (`"fork.knife"`, `"graduationcap.fill"`).
///
/// So this maps the known Lucide names across, passes anything else through unchanged (which
/// covers the in-app vocabulary), and falls back to a generic tag for names it doesn't know.
/// Every symbol below was verified to exist rather than assumed.
enum CategoryIconResolver {

	static let fallbackSymbol = "tag"

	/// Lucide name → SF Symbol, covering the backend's seeded category set.
	private static let lucideToSFSymbol: [String: String] = [
		// Expense
		"utensils": "fork.knife",
		"shopping-basket": "basket",
		"shopping-bag": "bag",
		"bus": "bus",
		"home": "house",
		"plane": "airplane",
		"zap": "bolt",
		"credit-card": "creditcard",
		"receipt": "receipt",
		"graduation-cap": "graduationcap",
		"film": "film",
		"heart-pulse": "heart.text.square",
		"shield": "shield",
		"minus-circle": "minus.circle",
		// Income
		"plus-circle": "plus.circle",
		"trending-up": "chart.line.uptrend.xyaxis",
		"rotate-ccw": "arrow.counterclockwise",
		"briefcase": "briefcase",
		"store": "storefront",
		"gift": "gift",
		"percent": "percent"
	]

	/// - Parameter icon: the raw stored value, in either vocabulary.
	/// - Returns: an SF Symbol name safe to hand to `Image(systemName:)`.
	static func symbol(for icon: String?) -> String {
		guard let icon, !icon.isEmpty else { return fallbackSymbol }

		if let mapped = lucideToSFSymbol[icon] {
			return mapped
		}

		// Already an SF Symbol (the in-app vocabulary) — SF names are dot-separated, never
		// kebab-cased, so a remaining hyphen means an unmapped Lucide name we'd render blank.
		return icon.contains("-") ? fallbackSymbol : icon
	}
}
