//
//  CurrencyRepository.swift
//  finance-test-ios
//

protocol CurrencyRepository {
	func getCurrencies(
		request: Currency.Request.GetCurrencies
	) async throws -> RequestState<GeneralResponse<Currency.Response.CurrencyList>>
}
