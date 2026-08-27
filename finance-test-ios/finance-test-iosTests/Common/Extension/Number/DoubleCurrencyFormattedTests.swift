//
//  DoubleCurrencyFormattedTests.swift
//  finance-test-iosTests
//

import Foundation
import Testing
@testable import finance_test_ios

/// Assertions deliberately check for the *presence* of the symbol and the fraction-digit count
/// rather than whole formatted strings — grouping/decimal separators follow the device locale, so
/// exact-string assertions would be fragile on a differently-configured machine.
@Suite("Double.currencyFormatted")
struct DoubleCurrencyFormattedTests {

	private static let usd = DisplayCurrency(code: "USD", symbol: "$", decimalPlaces: 2)
	private static let eur = DisplayCurrency(code: "EUR", symbol: "€", decimalPlaces: 2)
	private static let jpy = DisplayCurrency(code: "JPY", symbol: "¥", decimalPlaces: 0)

	// MARK: - The regression this ticket exists for

	/// Amounts used to render with no currency at all — assigning `positivePrefix` wiped the
	/// symbol, so a positive expense showed "75.00" while Siri said "$75.00".
	@Test(arguments: [0.0, 0.5, 75.0, 1234.56])
	func currencyFormatted_positiveAmount_includesTheSymbol(amount: Double) {
		#expect(amount.currencyFormatted(currency: Self.usd).contains("$"))
	}

	@Test(arguments: [0.0, 75.0, 1234.56])
	func currencyFormatted_withShowsSign_stillIncludesTheSymbol(amount: Double) {
		let formatted = amount.currencyFormatted(showsSign: true, currency: Self.usd)

		#expect(formatted.contains("$"))
		#expect(formatted.hasPrefix("+"))
	}

	@Test
	func currencyWholeFormatted_includesTheSymbol() {
		#expect(142800.0.currencyWholeFormatted(currency: Self.usd).contains("$"))
	}

	// MARK: - Currency awareness

	@Test
	func currencyFormatted_usesTheGivenCurrencysSymbol() {
		#expect(75.0.currencyFormatted(currency: Self.eur).contains("€"))
		#expect(!75.0.currencyFormatted(currency: Self.eur).contains("$"))
	}

	/// JPY has no minor unit, so forcing two decimals was wrong.
	@Test
	func currencyFormatted_respectsDecimalPlaces() {
		let jpy = 1234.0.currencyFormatted(currency: Self.jpy)
		let usd = 1234.0.currencyFormatted(currency: Self.usd)

		#expect(!jpy.contains("00"), "JPY should carry no fraction digits, got \(jpy)")
		#expect(usd.hasSuffix("00"), "USD should carry two fraction digits, got \(usd)")
	}

	// MARK: - Signs

	@Test
	func currencyFormatted_negativeAmount_keepsMinusAndSymbol() {
		let formatted = (-42.5).currencyFormatted(currency: Self.usd)

		#expect(formatted.contains("$"))
		#expect(formatted.contains("-"))
	}

	@Test
	func currencyFormatted_withoutShowsSign_hasNoPlusPrefix() {
		#expect(!75.0.currencyFormatted(currency: Self.usd).hasPrefix("+"))
	}

	// MARK: - Defaults

	@Test
	func displayCurrency_fallback_isUSD() {
		#expect(DisplayCurrency.fallback.code == "USD")
		#expect(DisplayCurrency.fallback.symbol == "$")
		#expect(DisplayCurrency.fallback.decimalPlaces == 2)
	}

	@Test
	func displayCurrency_fromWireModel_fallsBackPerMissingField() {
		let sparse = Currency.Response.CurrencyItem(
			id: "x", code: nil, name: nil, symbol: nil,
			decimalPlaces: nil, createdAt: nil, updatedAt: nil, deletedAt: nil
		)

		let currency = DisplayCurrency(item: sparse)

		#expect(currency.code == DisplayCurrency.fallback.code)
		#expect(currency.symbol == DisplayCurrency.fallback.symbol)
		#expect(currency.decimalPlaces == DisplayCurrency.fallback.decimalPlaces)
	}
}
