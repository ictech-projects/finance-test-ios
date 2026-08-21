//
//  UserCurrencyDisplayItem.swift
//  finance-test-ios
//

import Foundation

/// A user currency joined with its catalog entry — `UserCurrencyResource` only carries a
/// `currency_id`, so name/code/symbol come from `CurrencyRepository.getCurrencies()` and are
/// resolved client-side once, in `UserCurrenciesViewModel.onLoad()`.
struct UserCurrencyDisplayItem: Identifiable, Hashable {
	let item: UserCurrency.Response.UserCurrencyItem
	let currency: Currency.Response.CurrencyItem?

	var id: String { item.id ?? item.currencyId ?? "unknown" }
}
