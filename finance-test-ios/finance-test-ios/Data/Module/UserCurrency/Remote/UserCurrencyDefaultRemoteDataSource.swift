//
//  UserCurrencyDefaultRemoteDataSource.swift
//  finance-test-ios
//

import Moya

struct UserCurrencyDefaultRemoteDataSource: UserCurrencyRemoteDataSource {

	private let provider: MoyaProvider<UserCurrencyTargetType>

	init(provider: MoyaProvider<UserCurrencyTargetType> = .defaultProvider()) {
		self.provider = provider
	}

	func getUserCurrencies(
		request: UserCurrency.Request.GetUserCurrencies
	) async throws -> GeneralResponse<UserCurrency.Response.UserCurrencyList> {
		try await provider.request(
			.getUserCurrencies(request),
			model: GeneralResponse<UserCurrency.Response.UserCurrencyList>.self
		)
	}

	func createUserCurrency(
		request: UserCurrency.Request.CreateUserCurrency
	) async throws -> GeneralResponse<UserCurrency.Response.UserCurrencyItem> {
		try await provider.request(
			.createUserCurrency(request),
			model: GeneralResponse<UserCurrency.Response.UserCurrencyItem>.self
		)
	}
}
