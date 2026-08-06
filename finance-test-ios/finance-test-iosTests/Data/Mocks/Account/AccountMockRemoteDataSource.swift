//
//  AccountMockRemoteDataSource.swift
//  finance-test-iosTests
//

@testable import finance_test_ios

final class AccountMockRemoteDataSource: AccountRemoteDataSource {

	enum Invocation: Equatable {
		case getAccounts(Account.Request.GetAccounts)
	}

	private(set) var invocations: [Invocation] = []

	private let getAccountsResult: Result<GeneralResponse<Account.Response.AccountList>, Error>

	init(
		getAccountsResult: Result<GeneralResponse<Account.Response.AccountList>, Error> = .success(
			anyAccountListSuccessResponse()
		)
	) {
		self.getAccountsResult = getAccountsResult
	}

	func getAccounts(
		request: Account.Request.GetAccounts
	) async throws -> GeneralResponse<Account.Response.AccountList> {
		invocations.append(.getAccounts(request))
		return try getAccountsResult.get()
	}
}

func anyAccountItem(
	id: String = "01K3AC0000000000000000AC01",
	name: String = "Cash",
	type: String = "cash"
) -> Account.Response.AccountItem {
	Account.Response.AccountItem(
		id: id, userId: "01K3US0000000000000000US01", userCurrencyId: "01K3UC0000000000000000UC01",
		name: name, notes: nil, type: type, color: "#22C55E",
		initialBalance: "320", balance: "320", isDefault: true,
		createdAt: nil, updatedAt: nil, deletedAt: nil
	)
}

func anyGetAccountsRequest() -> Account.Request.GetAccounts {
	Account.Request.GetAccounts(since: nil)
}

func anyAccountListSuccessResponse(
	items: [Account.Response.AccountItem] = [anyAccountItem()]
) -> GeneralResponse<Account.Response.AccountList> {
	GeneralResponse(
		success: true,
		statusCode: 200,
		message: "Accounts fetched.",
		data: Account.Response.AccountList(items: items, serverTime: nil)
	)
}
