//
//  UserCurrencyRepository.swift
//  finance-test-ios
//

protocol UserCurrencyRepository {
	func getUserCurrencies(
		request: UserCurrency.Request.GetUserCurrencies
	) async throws -> RequestState<GeneralResponse<UserCurrency.Response.UserCurrencyList>>

	func createUserCurrency(
		request: UserCurrency.Request.CreateUserCurrency
	) async throws -> RequestState<GeneralResponse<UserCurrency.Response.UserCurrencyItem>>

	func updateUserCurrency(
		id: String,
		request: UserCurrency.Request.UpdateUserCurrency
	) async throws -> RequestState<GeneralResponse<UserCurrency.Response.UserCurrencyItem>>
}
