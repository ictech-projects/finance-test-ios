//
//  AccountMockRepository.swift
//  finance-test-ios
//

import Foundation

/// Stands in for `AccountDefaultRepository` until the auth module exists and `/accounts`
/// can actually be called. Swap the default in consuming ViewModels to `AccountDefaultRepository()`
/// once a valid access token is available.
struct AccountMockRepository: AccountRepository {

	func getAccounts(
		request: Account.Request.GetAccounts
	) async -> RequestState<GeneralResponse<Account.Response.AccountList>> {
		try? await Task.sleep(nanoseconds: 400_000_000)

		return .loaded(
			GeneralResponse(
				success: true,
				statusCode: 200,
				message: "Accounts fetched.",
				data: Account.Response.AccountList(items: Account.Response.AccountItem.mocks, serverTime: nil)
			)
		)
	}
}
