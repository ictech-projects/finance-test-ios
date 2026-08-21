//
//  AccountMockRepository.swift
//  finance-test-iosTests
//

@testable import finance_test_ios

/// Test double for `AccountRepository`, distinct from the app target's `AccountMockRepository`
/// (which stands in for the real backend until the auth module lands). This one lets each test
/// configure an arbitrary `RequestState` result and records invocations for assertions.
final class AccountMockRepository: AccountRepository {

	enum Invocation: Equatable {
		case getAccounts(Account.Request.GetAccounts)
		case createAccount(Account.Request.CreateAccount)
		case updateAccount(id: String, request: Account.Request.UpdateAccount)
	}

	private(set) var invocations: [Invocation] = []

	private let result: RequestState<GeneralResponse<Account.Response.AccountList>>
	private let createResult: RequestState<GeneralResponse<Account.Response.AccountItem>>
	private let updateResult: RequestState<GeneralResponse<Account.Response.AccountItem>>

	init(
		result: RequestState<GeneralResponse<Account.Response.AccountList>> = .idle,
		createResult: RequestState<GeneralResponse<Account.Response.AccountItem>> = .idle,
		updateResult: RequestState<GeneralResponse<Account.Response.AccountItem>> = .idle
	) {
		self.result = result
		self.createResult = createResult
		self.updateResult = updateResult
	}

	func getAccounts(
		request: Account.Request.GetAccounts
	) async throws -> RequestState<GeneralResponse<Account.Response.AccountList>> {
		invocations.append(.getAccounts(request))
		return result
	}

	func createAccount(
		request: Account.Request.CreateAccount
	) async throws -> RequestState<GeneralResponse<Account.Response.AccountItem>> {
		invocations.append(.createAccount(request))
		return createResult
	}

	func updateAccount(
		id: String,
		request: Account.Request.UpdateAccount
	) async throws -> RequestState<GeneralResponse<Account.Response.AccountItem>> {
		invocations.append(.updateAccount(id: id, request: request))
		return updateResult
	}
}
