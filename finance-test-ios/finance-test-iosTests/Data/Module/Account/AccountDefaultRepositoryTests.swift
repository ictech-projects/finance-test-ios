//
//  AccountDefaultRepositoryTests.swift
//  finance-test-iosTests
//

import Foundation
import Testing
@testable import finance_test_ios

@Suite("AccountDefaultRepository")
struct AccountDefaultRepositoryTests {

	// MARK: - Tests

	@Test func getAccounts_callsRemoteWithCorrectRequest() async throws {
		let remote = AccountMockRemoteDataSource(getAccountsResult: .success(anyAccountListSuccessResponse()))
		let sut = makeSUT(remote: remote)

		_ = try await sut.getAccounts(request: anyGetAccountsRequest())

		#expect(remote.invocations == [.getAccounts(anyGetAccountsRequest())])
	}

	@Test(arguments: [0, 1, 2])
	func getAccounts_withVaryingItemCounts_returnsMatchingList(itemCount: Int) async throws {
		let items = (0..<itemCount).map { anyAccountItem(id: "\($0)") }
		let remote = AccountMockRemoteDataSource(
			getAccountsResult: .success(anyAccountListSuccessResponse(items: items))
		)
		let sut = makeSUT(remote: remote)

		let result = try await sut.getAccounts(request: anyGetAccountsRequest())

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.data?.items?.count == itemCount)
	}

	@Test func getAccounts_success_returnsExpectedData() async throws {
		let response = anyAccountListSuccessResponse()
		let remote = AccountMockRemoteDataSource(getAccountsResult: .success(response))
		let sut = makeSUT(remote: remote)

		let result = try await sut.getAccounts(request: anyGetAccountsRequest())

		guard case .loaded(let loadedResponse) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(loadedResponse.success == true)
		#expect(loadedResponse.statusCode == 200)
		#expect(loadedResponse.data == response.data)
	}

	@Test(arguments: [401, 404, 500])
	func getAccounts_whenThrowsErrorResponse_returnsErrorState(statusCode: Int) async throws {
		let expectedError = ErrorResponse(success: false, statusCode: statusCode, message: "Request failed", errors: nil)
		let remote = AccountMockRemoteDataSource(getAccountsResult: .failure(expectedError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.getAccounts(request: anyGetAccountsRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == statusCode)
		#expect(error.message == "Request failed")
	}

	@Test func getAccounts_whenThrowsGenericError_returnsErrorState() async throws {
		let dummyError = NSError(domain: "TestError", code: 999)
		let remote = AccountMockRemoteDataSource(getAccountsResult: .failure(dummyError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.getAccounts(request: anyGetAccountsRequest())

		guard case .error(let error as NSError) = result else {
			Issue.record("Expected .error(NSError)")
			return
		}
		#expect(error.domain == "TestError")
		#expect(error.code == 999)
	}

	// MARK: - createAccount

	@Test func createAccount_callsRemoteWithCorrectRequest() async throws {
		let remote = AccountMockRemoteDataSource(createAccountResult: .success(anyAccountItemSuccessResponse()))
		let sut = makeSUT(remote: remote)

		_ = try await sut.createAccount(request: anyCreateAccountRequest())

		#expect(remote.invocations == [.createAccount(anyCreateAccountRequest())])
	}

	@Test func createAccount_success_returnsCreatedItem() async throws {
		let item = anyAccountItem(id: "01K3AC0000000000000000AC02", name: "Main Bank", type: "bank_account")
		let remote = AccountMockRemoteDataSource(createAccountResult: .success(anyAccountItemSuccessResponse(item: item)))
		let sut = makeSUT(remote: remote)

		let result = try await sut.createAccount(request: anyCreateAccountRequest())

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.data == item)
	}

	@Test func createAccount_whenThrowsErrorResponse_returnsErrorState() async throws {
		let expectedError = ErrorResponse(success: false, statusCode: 422, message: "Validation failed.", errors: nil)
		let remote = AccountMockRemoteDataSource(createAccountResult: .failure(expectedError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.createAccount(request: anyCreateAccountRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.message == "Validation failed.")
	}

	// MARK: - updateAccount

	// There is no `PATCH /accounts/{id}` — an update is submitted as a single-item `/sync/push`
	// batch, so these tests exercise the Sync collaborator rather than `AccountRemoteDataSource`,
	// mirroring `UserCurrencyDefaultRepositoryTests.updateUserCurrency`.

	@Test func updateAccount_callsSyncWithCorrectChange() async throws {
		let sync = SyncMockRepository(result: .loaded(anyPushSuccessResponse(results: [anyAppliedAccountChangeResult()])))
		let sut = makeSUT(sync: sync)

		_ = try await sut.updateAccount(id: "01K3AC0000000000000000AC02", request: anyUpdateAccountRequest())

		guard sync.invocations.count == 1, case .push(let pushRequest) = sync.invocations[0] else {
			Issue.record("Expected exactly one push invocation but got \(sync.invocations)")
			return
		}
		let change = try #require(pushRequest.changes.first)
		#expect(pushRequest.changes.count == 1)
		#expect(change.entity == "account")
		#expect(change.op == "update")
		#expect(change.id == "01K3AC0000000000000000AC02")
		let decodedData = try change.data?.decoded(as: Account.Request.UpdateAccount.self)
		#expect(decodedData == anyUpdateAccountRequest())
	}

	@Test func updateAccount_success_returnsUpdatedItem() async throws {
		let item = anyAccountItem(id: "01K3AC0000000000000000AC02", name: "Renamed Account", type: "bank_account")
		let sync = SyncMockRepository(
			result: .loaded(anyPushSuccessResponse(results: [anyAppliedAccountChangeResult(id: item.id, item: item)]))
		)
		let sut = makeSUT(sync: sync)

		let result = try await sut.updateAccount(id: "01K3AC0000000000000000AC02", request: anyUpdateAccountRequest())

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.data == item)
	}

	@Test func updateAccount_whenChangeFails_returnsErrorState() async throws {
		let failedResult = Sync.Response.ChangeResult(
			clientChangeId: "c1", id: "01K3AC0000000000000000AC02", entity: "account", status: "failed",
			record: nil,
			error: Sync.Response.ChangeError(message: "Invalid account type.", errors: ["type": ["invalid"]])
		)
		let sync = SyncMockRepository(result: .loaded(anyPushSuccessResponse(results: [failedResult])))
		let sut = makeSUT(sync: sync)

		let result = try await sut.updateAccount(id: "01K3AC0000000000000000AC02", request: anyUpdateAccountRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == 422)
		#expect(error.message == "Invalid account type.")
	}

	@Test(arguments: [401, 404, 500])
	func updateAccount_whenSyncThrowsErrorResponse_returnsErrorState(statusCode: Int) async throws {
		let expectedError = ErrorResponse(success: false, statusCode: statusCode, message: "Request failed", errors: nil)
		let sync = SyncMockRepository(result: .error(expectedError))
		let sut = makeSUT(sync: sync)

		let result = try await sut.updateAccount(id: "01K3AC0000000000000000AC02", request: anyUpdateAccountRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == statusCode)
	}

	// MARK: - Helpers

	// `AccountDefaultRepository` is a struct (per the codebase's Repository convention), so
	// there's no reference to leak — `trackForMemoryLeak` doesn't apply here.
	private func makeSUT(
		remote: AccountMockRemoteDataSource = AccountMockRemoteDataSource(),
		sync: SyncMockRepository = SyncMockRepository()
	) -> AccountDefaultRepository {
		AccountDefaultRepository(remote: remote, sync: sync)
	}
}
