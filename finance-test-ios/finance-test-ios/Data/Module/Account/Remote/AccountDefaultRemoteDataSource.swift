//
//  AccountDefaultRemoteDataSource.swift
//  finance-test-ios
//

import Moya

struct AccountDefaultRemoteDataSource: AccountRemoteDataSource {

	private let provider: MoyaProvider<AccountTargetType>

	init(provider: MoyaProvider<AccountTargetType> = .defaultProvider()) {
		self.provider = provider
	}

	func getAccounts(
		request: Account.Request.GetAccounts
	) async throws -> GeneralResponse<Account.Response.AccountList> {
		try await provider.request(
			.getAccounts(request),
			model: GeneralResponse<Account.Response.AccountList>.self
		)
	}

	func createAccount(
		request: Account.Request.CreateAccount
	) async throws -> GeneralResponse<Account.Response.AccountItem> {
		try await provider.request(
			.createAccount(request),
			model: GeneralResponse<Account.Response.AccountItem>.self
		)
	}
}
