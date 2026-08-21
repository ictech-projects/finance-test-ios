//
//  AccountRepository.swift
//  finance-test-ios
//

protocol AccountRepository {
	func getAccounts(
		request: Account.Request.GetAccounts
	) async throws -> RequestState<GeneralResponse<Account.Response.AccountList>>

	func createAccount(
		request: Account.Request.CreateAccount
	) async throws -> RequestState<GeneralResponse<Account.Response.AccountItem>>

	func updateAccount(
		id: String,
		request: Account.Request.UpdateAccount
	) async throws -> RequestState<GeneralResponse<Account.Response.AccountItem>>
}
