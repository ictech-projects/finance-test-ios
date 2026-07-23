//
//  CurrencyDefaultRepository.swift
//  finance-test-ios
//

import Foundation

struct CurrencyDefaultRepository: CurrencyRepository {

	private let remote: any CurrencyRemoteDataSource

	init(remote: some CurrencyRemoteDataSource = CurrencyDefaultRemoteDataSource()) {
		self.remote = remote
	}

	func getCurrencies(
		request: Currency.Request.GetCurrencies
	) async throws -> RequestState<GeneralResponse<Currency.Response.CurrencyList>> {
		await execute { try await remote.getCurrencies(request: request) }
	}
}
