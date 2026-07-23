//
//  CurrencyRemoteDataSource.swift
//  finance-test-ios
//

import Foundation

protocol CurrencyRemoteDataSource {
	func getCurrencies(
		request: Currency.Request.GetCurrencies
	) async throws -> GeneralResponse<Currency.Response.CurrencyList>
}
