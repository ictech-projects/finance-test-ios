//
//  DisplayCurrencyStoreTests.swift
//  finance-test-iosTests
//

import Foundation
import Testing
@testable import finance_test_ios

/// `.serialized` because `DisplayCurrency.setCurrent` is process-wide: parallel tests
/// mutating it would race each other.
@Suite("DisplayCurrencyDefaultStore", .serialized)
@MainActor
struct DisplayCurrencyStoreTests {

	private static let eurItem = Currency.Response.CurrencyItem(
		id: "eur", code: "EUR", name: "Euro", symbol: "€",
		decimalPlaces: 2, createdAt: nil, updatedAt: nil, deletedAt: nil
	)

	// MARK: - Resolving the anchor

	@Test
	func refresh_resolvesTheAnchorCurrencyFromTheCatalog() async {
		let sut = makeSUT(
			userCurrencies: [
				anyUserCurrencyItem(id: "uc-usd", currencyId: "usd", isAnchor: false),
				anyUserCurrencyItem(id: "uc-eur", currencyId: "eur", isAnchor: true)
			],
			catalog: [anyCurrencyItem(), Self.eurItem]
		)

		await sut.refresh()

		#expect(sut.current == DisplayCurrency(code: "EUR", symbol: "€", decimalPlaces: 2))
	}

	/// Mirrors `AccountFormViewModel`'s anchor resolution — a user whose currencies predate the
	/// flag has none marked, and the first is the best available guess.
	@Test
	func refresh_whenNoAnchorMarked_fallsBackToTheFirstUserCurrency() async {
		let sut = makeSUT(
			userCurrencies: [anyUserCurrencyItem(id: "uc-eur", currencyId: "eur", isAnchor: false)],
			catalog: [anyCurrencyItem(), Self.eurItem]
		)

		await sut.refresh()

		#expect(sut.current.code == "EUR")
	}

	@Test
	func refresh_mirrorsIntoTheValueTheFormatterReads() async {
		let original = DisplayCurrency.current
		defer { DisplayCurrency.setCurrent(original) }

		let sut = makeSUT(
			userCurrencies: [anyUserCurrencyItem(currencyId: "eur", isAnchor: true)],
			catalog: [Self.eurItem]
		)

		await sut.refresh()

		#expect(DisplayCurrency.current == sut.current)
		#expect(1.0.currencyFormatted().contains("€"))
	}

	// MARK: - Leaving state alone on failure

	@Test
	func refresh_whenUserCurrenciesFail_keepsThePreviousCurrency() async {
		let sut = DisplayCurrencyDefaultStore(
			userCurrencyRepository: UserCurrencyMockRepository(result: .error(NSError(domain: "", code: -1))),
			currencyRepository: CurrencyMockRepository(result: .loaded(anyCurrencyListSuccessResponse())),
			current: .fallback
		)

		await sut.refresh()

		#expect(sut.current == .fallback)
	}

	@Test
	func refresh_whenTheAnchorIsNotInTheCatalog_keepsThePreviousCurrency() async {
		let sut = makeSUT(
			userCurrencies: [anyUserCurrencyItem(currencyId: "currency-not-in-catalog", isAnchor: true)],
			catalog: [anyCurrencyItem()]
		)

		await sut.refresh()

		#expect(sut.current == .fallback)
	}

	@Test
	func refresh_whenUserHasNoCurrencies_keepsThePreviousCurrency() async {
		let sut = makeSUT(userCurrencies: [], catalog: [anyCurrencyItem()])

		await sut.refresh()

		#expect(sut.current == .fallback)
	}

	// MARK: - Helpers

	private func makeSUT(
		userCurrencies: [UserCurrency.Response.UserCurrencyItem],
		catalog: [Currency.Response.CurrencyItem],
		current: DisplayCurrency = .fallback
	) -> DisplayCurrencyDefaultStore {
		DisplayCurrencyDefaultStore(
			userCurrencyRepository: UserCurrencyMockRepository(
				result: .loaded(anyUserCurrencyListSuccessResponse(items: userCurrencies))
			),
			currencyRepository: CurrencyMockRepository(
				result: .loaded(anyCurrencyListSuccessResponse(items: catalog))
			),
			current: current
		)
	}
}
