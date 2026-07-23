//
//  CurrencyMockRepository.swift
//  finance-test-iosTests
//

@testable import finance_test_ios

/// Test double for `CurrencyRepository`, distinct from the app target's `CurrencyMockRepository`
/// (which stands in for the real backend until the auth module lands). This one lets each test
/// configure an arbitrary `RequestState` result and records invocations for assertions.
final class CurrencyMockRepository: CurrencyRepository {

	enum Invocation: Equatable {
		case getCurrencies(Currency.Request.GetCurrencies)
	}

	private(set) var invocations: [Invocation] = []

	private let result: RequestState<GeneralResponse<Currency.Response.CurrencyList>>

	init(result: RequestState<GeneralResponse<Currency.Response.CurrencyList>> = .idle) {
		self.result = result
	}

	func getCurrencies(
		request: Currency.Request.GetCurrencies
	) async throws -> RequestState<GeneralResponse<Currency.Response.CurrencyList>> {
		invocations.append(.getCurrencies(request))
		return result
	}
}
