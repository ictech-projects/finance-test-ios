//
//  AccountDefaultRepository.swift
//  finance-test-ios
//

import Foundation

struct AccountDefaultRepository: AccountRepository {

	private let remote: any AccountRemoteDataSource

	init(remote: some AccountRemoteDataSource = AccountDefaultRemoteDataSource()) {
		self.remote = remote
	}

	func getAccounts(
		request: Account.Request.GetAccounts
	) async throws -> RequestState<GeneralResponse<Account.Response.AccountList>> {
		await execute { try await remote.getAccounts(request: request) }
	}
}
