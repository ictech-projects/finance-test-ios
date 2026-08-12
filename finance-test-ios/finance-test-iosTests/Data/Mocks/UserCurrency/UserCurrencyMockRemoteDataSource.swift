//
//  UserCurrencyMockRemoteDataSource.swift
//  finance-test-iosTests
//

@testable import finance_test_ios

final class UserCurrencyMockRemoteDataSource: UserCurrencyRemoteDataSource {

	enum Invocation: Equatable {
		case getUserCurrencies(UserCurrency.Request.GetUserCurrencies)
		case createUserCurrency(UserCurrency.Request.CreateUserCurrency)
	}

	private(set) var invocations: [Invocation] = []

	private let getUserCurrenciesResult: Result<GeneralResponse<UserCurrency.Response.UserCurrencyList>, Error>
	private let createUserCurrencyResult: Result<GeneralResponse<UserCurrency.Response.UserCurrencyItem>, Error>

	init(
		getUserCurrenciesResult: Result<GeneralResponse<UserCurrency.Response.UserCurrencyList>, Error> = .success(
			anyUserCurrencyListSuccessResponse()
		),
		createUserCurrencyResult: Result<GeneralResponse<UserCurrency.Response.UserCurrencyItem>, Error> = .success(
			anyUserCurrencyItemSuccessResponse()
		)
	) {
		self.getUserCurrenciesResult = getUserCurrenciesResult
		self.createUserCurrencyResult = createUserCurrencyResult
	}

	func getUserCurrencies(
		request: UserCurrency.Request.GetUserCurrencies
	) async throws -> GeneralResponse<UserCurrency.Response.UserCurrencyList> {
		invocations.append(.getUserCurrencies(request))
		return try getUserCurrenciesResult.get()
	}

	func createUserCurrency(
		request: UserCurrency.Request.CreateUserCurrency
	) async throws -> GeneralResponse<UserCurrency.Response.UserCurrencyItem> {
		invocations.append(.createUserCurrency(request))
		return try createUserCurrencyResult.get()
	}
}

func anyUserCurrencyItem(
	id: String = "01K3UC0000000000000000UC01",
	currencyId: String = "usd",
	exchangeRate: String = "1",
	isAnchor: Bool = true
) -> UserCurrency.Response.UserCurrencyItem {
	UserCurrency.Response.UserCurrencyItem(
		id: id, userId: "01K3US0000000000000000US01", currencyId: currencyId,
		exchangeRate: exchangeRate, isAnchor: isAnchor, createdAt: nil, updatedAt: nil
	)
}

func anyGetUserCurrenciesRequest() -> UserCurrency.Request.GetUserCurrencies {
	UserCurrency.Request.GetUserCurrencies(since: nil)
}

func anyCreateUserCurrencyRequest(
	currencyId: String = "eur",
	exchangeRate: String? = "0.9245",
	isAnchor: Bool? = false
) -> UserCurrency.Request.CreateUserCurrency {
	UserCurrency.Request.CreateUserCurrency(currencyId: currencyId, exchangeRate: exchangeRate, isAnchor: isAnchor)
}

func anyUpdateUserCurrencyRequest(
	currencyId: String = "eur",
	exchangeRate: String? = "1.05",
	isAnchor: Bool? = false
) -> UserCurrency.Request.UpdateUserCurrency {
	UserCurrency.Request.UpdateUserCurrency(currencyId: currencyId, exchangeRate: exchangeRate, isAnchor: isAnchor)
}

func anyAppliedUserCurrencyChangeResult(
	clientChangeId: String? = "c1",
	id: String? = "01K3UC0000000000000000UC02",
	item: UserCurrency.Response.UserCurrencyItem = anyUserCurrencyItem(id: "01K3UC0000000000000000UC02", currencyId: "eur", exchangeRate: "1.05", isAnchor: false)
) -> Sync.Response.ChangeResult {
	Sync.Response.ChangeResult(
		clientChangeId: clientChangeId, id: id, entity: "user_currency", status: "applied",
		record: try? JSONValue(encoding: item), error: nil
	)
}

func anyUserCurrencyListSuccessResponse(
	items: [UserCurrency.Response.UserCurrencyItem] = [anyUserCurrencyItem()]
) -> GeneralResponse<UserCurrency.Response.UserCurrencyList> {
	GeneralResponse(
		success: true,
		statusCode: 200,
		message: "User currencies fetched.",
		data: UserCurrency.Response.UserCurrencyList(items: items, serverTime: nil)
	)
}

func anyUserCurrencyItemSuccessResponse(
	item: UserCurrency.Response.UserCurrencyItem = anyUserCurrencyItem()
) -> GeneralResponse<UserCurrency.Response.UserCurrencyItem> {
	GeneralResponse(
		success: true,
		statusCode: 201,
		message: "User currency added.",
		data: item
	)
}
