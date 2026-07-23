//
//  CurrencyMockRepository.swift
//  finance-test-ios
//

import Foundation

/// Stands in for `CurrencyDefaultRepository` until the auth module exists and `/currencies`
/// can actually be called. Swap the default in consuming ViewModels to `CurrencyDefaultRepository()`
/// once a valid access token is available.
struct CurrencyMockRepository: CurrencyRepository {

	func getCurrencies(
		request: Currency.Request.GetCurrencies
	) async -> RequestState<GeneralResponse<Currency.Response.CurrencyList>> {
		try? await Task.sleep(nanoseconds: 400_000_000)

		return .loaded(
			GeneralResponse(
				success: true,
				statusCode: 200,
				message: "Currencies fetched.",
				data: Currency.Response.CurrencyList(
					items: Currency.Response.CurrencyItem.mocks,
					serverTime: nil
				)
			)
		)
	}
}
