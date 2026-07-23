//
//  CurrencyDefaultRemoteDataSource.swift
//  finance-test-ios
//

import Moya

struct CurrencyDefaultRemoteDataSource: CurrencyRemoteDataSource {

	private let provider: MoyaProvider<CurrencyTargetType>

	init(provider: MoyaProvider<CurrencyTargetType> = .defaultProvider()) {
		self.provider = provider
	}

	func getCurrencies(
		request: Currency.Request.GetCurrencies
	) async throws -> GeneralResponse<Currency.Response.CurrencyList> {
		try await provider.request(
			.getCurrencies(request),
			model: GeneralResponse<Currency.Response.CurrencyList>.self
		)
	}
}
