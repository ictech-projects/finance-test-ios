//
//  Double+currencyFormatted.swift
//  finance-test-ios
//

import Foundation

extension Double {

	/// Formats an amount in the user's display currency.
	///
	/// - Parameters:
	///   - showsSign: prefixes positive amounts with `+`. Negative amounts always keep their `-`.
	///   - currency: defaults to the app-wide display currency (the user's anchor). Pass one
	///     explicitly in tests, or wherever a specific currency is being rendered.
	func currencyFormatted(showsSign: Bool = false, currency: DisplayCurrency = .current) -> String {
		Self.string(
			from: self,
			currency: currency,
			fractionDigits: currency.decimalPlaces,
			showsSign: showsSign
		)
	}

	/// Same, but with no fraction digits — for the large headline figures on Home and Reports.
	func currencyWholeFormatted(currency: DisplayCurrency = .current) -> String {
		Self.string(from: self, currency: currency, fractionDigits: 0, showsSign: false)
	}

	private static func string(
		from value: Double,
		currency: DisplayCurrency,
		fractionDigits: Int,
		showsSign: Bool
	) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencyCode = currency.code
		formatter.currencySymbol = currency.symbol
		// `locale` is intentionally left as the device's: the *symbol* belongs to the currency,
		// but grouping/decimal separators belong to the reader — an Indonesian user sees
		// "$75,00", which is how iOS itself renders a foreign currency. Setting the currency's
		// home locale instead would force US conventions on everyone.
		formatter.minimumFractionDigits = fractionDigits
		formatter.maximumFractionDigits = fractionDigits

		// `positivePrefix`/`negativePrefix` are where a currency formatter keeps the symbol, so
		// they must be *appended to*, never assigned — assigning `""` or `"+"` silently deletes
		// the symbol, which is why amounts rendered with no currency at all.
		if showsSign {
			formatter.positivePrefix = "+" + formatter.positivePrefix
		}

		guard let formatted = formatter.string(from: NSNumber(value: value)) else {
			return currency.symbol + "0"
		}
		return formatted
	}
}
