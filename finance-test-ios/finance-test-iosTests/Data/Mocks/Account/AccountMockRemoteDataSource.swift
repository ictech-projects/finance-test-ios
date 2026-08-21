//
//  AccountMockRemoteDataSource.swift
//  finance-test-iosTests
//

@testable import finance_test_ios

final class AccountMockRemoteDataSource: AccountRemoteDataSource {

	enum Invocation: Equatable {
		case getAccounts(Account.Request.GetAccounts)
		case createAccount(Account.Request.CreateAccount)
	}

	private(set) var invocations: [Invocation] = []

	private let getAccountsResult: Result<GeneralResponse<Account.Response.AccountList>, Error>
	private let createAccountResult: Result<GeneralResponse<Account.Response.AccountItem>, Error>

	init(
		getAccountsResult: Result<GeneralResponse<Account.Response.AccountList>, Error> = .success(
			anyAccountListSuccessResponse()
		),
		createAccountResult: Result<GeneralResponse<Account.Response.AccountItem>, Error> = .success(
			anyAccountItemSuccessResponse()
		)
	) {
		self.getAccountsResult = getAccountsResult
		self.createAccountResult = createAccountResult
	}

	func getAccounts(
		request: Account.Request.GetAccounts
	) async throws -> GeneralResponse<Account.Response.AccountList> {
		invocations.append(.getAccounts(request))
		return try getAccountsResult.get()
	}

	func createAccount(
		request: Account.Request.CreateAccount
	) async throws -> GeneralResponse<Account.Response.AccountItem> {
		invocations.append(.createAccount(request))
		return try createAccountResult.get()
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

func anyCreateAccountRequest(
	userCurrencyId: String = "01K3UC0000000000000000UC01",
	name: String = "Main Bank",
	type: String = "bank_account",
	notes: String? = nil,
	color: String? = "#24389C",
	initialBalance: String? = "100",
	isDefault: Bool? = nil
) -> Account.Request.CreateAccount {
	Account.Request.CreateAccount(
		userCurrencyId: userCurrencyId, name: name, type: type, notes: notes,
		color: color, initialBalance: initialBalance, isDefault: isDefault
	)
}

func anyUpdateAccountRequest(
	userCurrencyId: String = "01K3UC0000000000000000UC01",
	name: String = "Main Bank",
	type: String = "bank_account",
	notes: String? = nil,
	color: String? = "#24389C",
	initialBalance: String? = "100",
	isDefault: Bool? = nil
) -> Account.Request.UpdateAccount {
	Account.Request.UpdateAccount(
		userCurrencyId: userCurrencyId, name: name, type: type, notes: notes,
		color: color, initialBalance: initialBalance, isDefault: isDefault
	)
}

func anyAccountItemSuccessResponse(
	item: Account.Response.AccountItem = anyAccountItem()
) -> GeneralResponse<Account.Response.AccountItem> {
	GeneralResponse(
		success: true,
		statusCode: 201,
		message: "Account added.",
		data: item
	)
}

func anyAppliedAccountChangeResult(
	clientChangeId: String? = "c1",
	id: String? = "01K3AC0000000000000000AC02",
	item: Account.Response.AccountItem = anyAccountItem(id: "01K3AC0000000000000000AC02")
) -> Sync.Response.ChangeResult {
	Sync.Response.ChangeResult(
		clientChangeId: clientChangeId, id: id, entity: "account", status: "applied",
		record: try? JSONValue(encoding: item), error: nil
	)
}
