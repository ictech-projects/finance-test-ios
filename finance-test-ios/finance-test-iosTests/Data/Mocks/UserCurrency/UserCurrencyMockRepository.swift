//
//  UserCurrencyMockRepository.swift
//  finance-test-iosTests
//

@testable import finance_test_ios

/// Test double for `UserCurrencyRepository`, distinct from the app target's
/// `UserCurrencyMockRepository` (which stands in for the real backend with fixed responses).
/// This one lets each test configure an arbitrary `RequestState` result and records invocations
/// for assertions.
final class UserCurrencyMockRepository: UserCurrencyRepository {

	enum Invocation: Equatable {
		case getUserCurrencies(UserCurrency.Request.GetUserCurrencies)
		case createUserCurrency(UserCurrency.Request.CreateUserCurrency)
		case updateUserCurrency(id: String, request: UserCurrency.Request.UpdateUserCurrency)
	}

	private(set) var invocations: [Invocation] = []

	private let result: RequestState<GeneralResponse<UserCurrency.Response.UserCurrencyList>>
	private let createResult: RequestState<GeneralResponse<UserCurrency.Response.UserCurrencyItem>>
	private let updateResult: RequestState<GeneralResponse<UserCurrency.Response.UserCurrencyItem>>

	init(
		result: RequestState<GeneralResponse<UserCurrency.Response.UserCurrencyList>> = .idle,
		createResult: RequestState<GeneralResponse<UserCurrency.Response.UserCurrencyItem>> = .idle,
		updateResult: RequestState<GeneralResponse<UserCurrency.Response.UserCurrencyItem>> = .idle
	) {
		self.result = result
		self.createResult = createResult
		self.updateResult = updateResult
	}

	func getUserCurrencies(
		request: UserCurrency.Request.GetUserCurrencies
	) async throws -> RequestState<GeneralResponse<UserCurrency.Response.UserCurrencyList>> {
		invocations.append(.getUserCurrencies(request))
		return result
	}

	func createUserCurrency(
		request: UserCurrency.Request.CreateUserCurrency
	) async throws -> RequestState<GeneralResponse<UserCurrency.Response.UserCurrencyItem>> {
		invocations.append(.createUserCurrency(request))
		return createResult
	}

	func updateUserCurrency(
		id: String,
		request: UserCurrency.Request.UpdateUserCurrency
	) async throws -> RequestState<GeneralResponse<UserCurrency.Response.UserCurrencyItem>> {
		invocations.append(.updateUserCurrency(id: id, request: request))
		return updateResult
	}
}
