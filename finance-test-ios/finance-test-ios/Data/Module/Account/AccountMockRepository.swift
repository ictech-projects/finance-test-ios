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

	func createAccount(
		request: Account.Request.CreateAccount
	) async -> RequestState<GeneralResponse<Account.Response.AccountItem>> {
		try? await Task.sleep(nanoseconds: 400_000_000)

		return .loaded(
			GeneralResponse(
				success: true,
				statusCode: 201,
				message: "Account added.",
				data: Account.Response.AccountItem(
					id: "01K3AC0000000000000000AC99", userId: "01K3US0000000000000000US01",
					userCurrencyId: request.userCurrencyId, name: request.name, notes: request.notes,
					type: request.type, color: request.color, initialBalance: request.initialBalance,
					balance: request.initialBalance, isDefault: request.isDefault,
					createdAt: nil, updatedAt: nil, deletedAt: nil
				)
			)
		)
	}

	func updateAccount(
		id: String,
		request: Account.Request.UpdateAccount
	) async -> RequestState<GeneralResponse<Account.Response.AccountItem>> {
		try? await Task.sleep(nanoseconds: 400_000_000)

		return .loaded(
			GeneralResponse(
				success: true,
				statusCode: 200,
				message: "Account updated.",
				data: Account.Response.AccountItem(
					id: id, userId: "01K3US0000000000000000US01",
					userCurrencyId: request.userCurrencyId, name: request.name, notes: request.notes,
					type: request.type, color: request.color, initialBalance: request.initialBalance,
					balance: request.initialBalance, isDefault: request.isDefault,
					createdAt: nil, updatedAt: nil, deletedAt: nil
				)
			)
		)
	}
}
