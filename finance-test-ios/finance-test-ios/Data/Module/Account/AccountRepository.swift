//
//  AccountRepository.swift
//  finance-test-ios
//

protocol AccountRepository {
	func getAccounts(
		request: Account.Request.GetAccounts
	) async throws -> RequestState<GeneralResponse<Account.Response.AccountList>>
}
