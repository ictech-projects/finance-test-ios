//
//  UserCurrencyRemoteDataSource.swift
//  finance-test-ios
//

protocol UserCurrencyRemoteDataSource {
	func getUserCurrencies(
		request: UserCurrency.Request.GetUserCurrencies
	) async throws -> GeneralResponse<UserCurrency.Response.UserCurrencyList>

	func createUserCurrency(
		request: UserCurrency.Request.CreateUserCurrency
	) async throws -> GeneralResponse<UserCurrency.Response.UserCurrencyItem>
}
