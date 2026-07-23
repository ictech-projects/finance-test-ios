//
//  CurrencyMockRemoteDataSource.swift
//  finance-test-iosTests
//

@testable import finance_test_ios

final class CurrencyMockRemoteDataSource: CurrencyRemoteDataSource {

	enum Invocation: Equatable {
		case getCurrencies(Currency.Request.GetCurrencies)
	}

	private(set) var invocations: [Invocation] = []

	private let getCurrenciesResult: Result<GeneralResponse<Currency.Response.CurrencyList>, Error>

	init(
		getCurrenciesResult: Result<GeneralResponse<Currency.Response.CurrencyList>, Error> = .success(
			anyCurrencyListSuccessResponse()
		)
	) {
		self.getCurrenciesResult = getCurrenciesResult
	}

	func getCurrencies(
		request: Currency.Request.GetCurrencies
	) async throws -> GeneralResponse<Currency.Response.CurrencyList> {
		invocations.append(.getCurrencies(request))
		return try getCurrenciesResult.get()
	}
}

func anyCurrencyItem(
	id: String = "usd",
	code: String = "USD",
	name: String = "US Dollar",
	symbol: String = "$"
) -> Currency.Response.CurrencyItem {
	Currency.Response.CurrencyItem(
		id: id, code: code, name: name, symbol: symbol,
		decimalPlaces: 2, createdAt: nil, updatedAt: nil, deletedAt: nil
	)
}

func anyGetCurrenciesRequest() -> Currency.Request.GetCurrencies {
	Currency.Request.GetCurrencies(since: nil)
}

func anyCurrencyListSuccessResponse(
	items: [Currency.Response.CurrencyItem] = [anyCurrencyItem()]
) -> GeneralResponse<Currency.Response.CurrencyList> {
	GeneralResponse(
		success: true,
		statusCode: 200,
		message: "Currencies fetched.",
		data: Currency.Response.CurrencyList(items: items, serverTime: nil)
	)
}
