//
//  UserCurrencyDefaultRepositoryTests.swift
//  finance-test-iosTests
//

import Foundation
import Testing
@testable import finance_test_ios

@Suite("UserCurrencyDefaultRepository")
struct UserCurrencyDefaultRepositoryTests {

	// MARK: - getUserCurrencies

	@Test func getUserCurrencies_callsRemoteWithCorrectRequest() async throws {
		let remote = UserCurrencyMockRemoteDataSource(getUserCurrenciesResult: .success(anyUserCurrencyListSuccessResponse()))
		let sut = makeSUT(remote: remote)

		_ = try await sut.getUserCurrencies(request: anyGetUserCurrenciesRequest())

		#expect(remote.invocations == [.getUserCurrencies(anyGetUserCurrenciesRequest())])
	}

	@Test func getUserCurrencies_success_returnsExpectedData() async throws {
		let response = anyUserCurrencyListSuccessResponse()
		let remote = UserCurrencyMockRemoteDataSource(getUserCurrenciesResult: .success(response))
		let sut = makeSUT(remote: remote)

		let result = try await sut.getUserCurrencies(request: anyGetUserCurrenciesRequest())

		guard case .loaded(let loadedResponse) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(loadedResponse.data == response.data)
	}

	@Test(arguments: [401, 404, 500])
	func getUserCurrencies_whenThrowsErrorResponse_returnsErrorState(statusCode: Int) async throws {
		let expectedError = ErrorResponse(success: false, statusCode: statusCode, message: "Request failed", errors: nil)
		let remote = UserCurrencyMockRemoteDataSource(getUserCurrenciesResult: .failure(expectedError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.getUserCurrencies(request: anyGetUserCurrenciesRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == statusCode)
	}

	// MARK: - createUserCurrency

	@Test func createUserCurrency_callsRemoteWithCorrectRequest() async throws {
		let remote = UserCurrencyMockRemoteDataSource(createUserCurrencyResult: .success(anyUserCurrencyItemSuccessResponse()))
		let sut = makeSUT(remote: remote)

		_ = try await sut.createUserCurrency(request: anyCreateUserCurrencyRequest())

		#expect(remote.invocations == [.createUserCurrency(anyCreateUserCurrencyRequest())])
	}

	@Test func createUserCurrency_success_returnsCreatedItem() async throws {
		let item = anyUserCurrencyItem(id: "01K3UC0000000000000000UC02", currencyId: "eur")
		let remote = UserCurrencyMockRemoteDataSource(createUserCurrencyResult: .success(anyUserCurrencyItemSuccessResponse(item: item)))
		let sut = makeSUT(remote: remote)

		let result = try await sut.createUserCurrency(request: anyCreateUserCurrencyRequest())

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.data == item)
	}

	@Test func createUserCurrency_whenThrowsErrorResponse_returnsErrorState() async throws {
		let expectedError = ErrorResponse(success: false, statusCode: 422, message: "Currency already added.", errors: nil)
		let remote = UserCurrencyMockRemoteDataSource(createUserCurrencyResult: .failure(expectedError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.createUserCurrency(request: anyCreateUserCurrencyRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.message == "Currency already added.")
	}

	// MARK: - updateUserCurrency

	// There is no `PATCH /user-currencies/{id}` — an update is submitted as a single-item
	// `/sync/push` batch, so these tests exercise the Sync collaborator rather than
	// `UserCurrencyRemoteDataSource`, mirroring `TransactionDefaultRepositoryTests.createTransaction`.

	@Test func updateUserCurrency_callsSyncWithCorrectChange() async throws {
		let sync = SyncMockRepository(result: .loaded(anyPushSuccessResponse(results: [anyAppliedUserCurrencyChangeResult()])))
		let sut = makeSUT(sync: sync)

		_ = try await sut.updateUserCurrency(id: "01K3UC0000000000000000UC02", request: anyUpdateUserCurrencyRequest())

		guard sync.invocations.count == 1, case .push(let pushRequest) = sync.invocations[0] else {
			Issue.record("Expected exactly one push invocation but got \(sync.invocations)")
			return
		}
		let change = try #require(pushRequest.changes.first)
		#expect(pushRequest.changes.count == 1)
		#expect(change.entity == "user_currency")
		#expect(change.op == "update")
		#expect(change.id == "01K3UC0000000000000000UC02")
		let decodedData = try change.data?.decoded(as: UserCurrency.Request.UpdateUserCurrency.self)
		#expect(decodedData == anyUpdateUserCurrencyRequest())
	}

	@Test func updateUserCurrency_success_returnsUpdatedItem() async throws {
		let item = anyUserCurrencyItem(id: "01K3UC0000000000000000UC02", currencyId: "eur", exchangeRate: "1.05", isAnchor: false)
		let sync = SyncMockRepository(
			result: .loaded(anyPushSuccessResponse(results: [anyAppliedUserCurrencyChangeResult(id: item.id, item: item)]))
		)
		let sut = makeSUT(sync: sync)

		let result = try await sut.updateUserCurrency(id: "01K3UC0000000000000000UC02", request: anyUpdateUserCurrencyRequest())

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.data == item)
	}

	@Test func updateUserCurrency_whenChangeFails_returnsErrorState() async throws {
		let failedResult = Sync.Response.ChangeResult(
			clientChangeId: "c1", id: "01K3UC0000000000000000UC02", entity: "user_currency", status: "failed",
			record: nil,
			error: Sync.Response.ChangeError(message: "Invalid exchange rate.", errors: ["data": ["invalid"]])
		)
		let sync = SyncMockRepository(result: .loaded(anyPushSuccessResponse(results: [failedResult])))
		let sut = makeSUT(sync: sync)

		let result = try await sut.updateUserCurrency(id: "01K3UC0000000000000000UC02", request: anyUpdateUserCurrencyRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == 422)
		#expect(error.message == "Invalid exchange rate.")
	}

	@Test(arguments: [401, 404, 500])
	func updateUserCurrency_whenSyncThrowsErrorResponse_returnsErrorState(statusCode: Int) async throws {
		let expectedError = ErrorResponse(success: false, statusCode: statusCode, message: "Request failed", errors: nil)
		let sync = SyncMockRepository(result: .error(expectedError))
		let sut = makeSUT(sync: sync)

		let result = try await sut.updateUserCurrency(id: "01K3UC0000000000000000UC02", request: anyUpdateUserCurrencyRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == statusCode)
	}

	// MARK: - Helpers

	// `UserCurrencyDefaultRepository` is a struct (per the codebase's Repository convention), so
	// there's no reference to leak — `trackForMemoryLeak` doesn't apply here.
	private func makeSUT(
		remote: UserCurrencyMockRemoteDataSource = UserCurrencyMockRemoteDataSource(),
		sync: SyncMockRepository = SyncMockRepository()
	) -> UserCurrencyDefaultRepository {
		UserCurrencyDefaultRepository(remoteDataSource: remote, sync: sync)
	}
}
