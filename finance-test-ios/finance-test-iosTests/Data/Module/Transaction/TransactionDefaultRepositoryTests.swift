//
//  TransactionDefaultRepositoryTests.swift
//  finance-test-iosTests
//

import Foundation
import Testing
@testable import finance_test_ios

@Suite("TransactionDefaultRepository")
struct TransactionDefaultRepositoryTests {

	// MARK: - Tests

	@Test func getTransactions_callsRemoteWithCorrectRequest() async throws {
		let remote = TransactionMockRemoteDataSource(getTransactionsResult: .success(anyTransactionListSuccessResponse()))
		let sut = makeSUT(remote: remote)

		_ = try await sut.getTransactions(request: anyGetTransactionsRequest())

		#expect(remote.invocations == [.getTransactions(anyGetTransactionsRequest())])
	}

	@Test(arguments: [0, 1, 2])
	func getTransactions_withVaryingItemCounts_returnsMatchingList(itemCount: Int) async throws {
		let items = (0..<itemCount).map { anyTransactionItem(id: "\($0)") }
		let remote = TransactionMockRemoteDataSource(
			getTransactionsResult: .success(anyTransactionListSuccessResponse(items: items))
		)
		let sut = makeSUT(remote: remote)

		let result = try await sut.getTransactions(request: anyGetTransactionsRequest())

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.data?.items?.count == itemCount)
	}

	@Test func getTransactions_success_returnsExpectedData() async throws {
		let response = anyTransactionListSuccessResponse()
		let remote = TransactionMockRemoteDataSource(getTransactionsResult: .success(response))
		let sut = makeSUT(remote: remote)

		let result = try await sut.getTransactions(request: anyGetTransactionsRequest())

		guard case .loaded(let loadedResponse) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(loadedResponse.success == true)
		#expect(loadedResponse.statusCode == 200)
		#expect(loadedResponse.data == response.data)
	}

	@Test(arguments: [401, 404, 500])
	func getTransactions_whenThrowsErrorResponse_returnsErrorState(statusCode: Int) async throws {
		let expectedError = ErrorResponse(success: false, statusCode: statusCode, message: "Request failed", errors: nil)
		let remote = TransactionMockRemoteDataSource(getTransactionsResult: .failure(expectedError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.getTransactions(request: anyGetTransactionsRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == statusCode)
		#expect(error.message == "Request failed")
	}

	@Test func getTransactions_whenThrowsGenericError_returnsErrorState() async throws {
		let dummyError = NSError(domain: "TestError", code: 999)
		let remote = TransactionMockRemoteDataSource(getTransactionsResult: .failure(dummyError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.getTransactions(request: anyGetTransactionsRequest())

		guard case .error(let error as NSError) = result else {
			Issue.record("Expected .error(NSError)")
			return
		}
		#expect(error.domain == "TestError")
		#expect(error.code == 999)
	}

	// MARK: - createTransaction

	// There is no `POST /transactions` — creation is submitted as a single-item `/sync/push`
	// batch, so these tests exercise the Sync collaborator rather than `TransactionRemoteDataSource`.

	@Test func createTransaction_callsSyncWithCorrectChange() async throws {
		let sync = SyncMockRepository(result: .loaded(anyPushSuccessResponse(results: [anyAppliedTransactionChangeResult()])))
		let sut = makeSUT(sync: sync)

		_ = try await sut.createTransaction(request: anyCreateTransactionRequest())

		guard sync.invocations.count == 1, case .push(let pushRequest) = sync.invocations[0] else {
			Issue.record("Expected exactly one push invocation but got \(sync.invocations)")
			return
		}
		let change = try #require(pushRequest.changes.first)
		#expect(pushRequest.changes.count == 1)
		#expect(change.entity == "transaction")
		#expect(change.op == "create")
		let decodedData = try change.data?.decoded(as: TransactionRecord.Request.CreateTransaction.self)
		#expect(decodedData == anyCreateTransactionRequest())
	}

	@Test func createTransaction_success_returnsCreatedItem() async throws {
		let item = anyTransactionItem(id: "01K3TX0000000000000000TX09")
		let sync = SyncMockRepository(
			result: .loaded(anyPushSuccessResponse(results: [anyAppliedTransactionChangeResult(id: item.id, item: item)]))
		)
		let sut = makeSUT(sync: sync)

		let result = try await sut.createTransaction(request: anyCreateTransactionRequest())

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.success == true)
		#expect(response.data == item)
	}

	@Test func createTransaction_whenChangeFails_returnsErrorState() async throws {
		let failedResult = Sync.Response.ChangeResult(
			clientChangeId: "c1", id: "01K3TX0000000000000000TX01", entity: "transaction", status: "failed",
			record: nil,
			error: Sync.Response.ChangeError(
				message: "The selected account or category is invalid.", errors: ["data": ["invalid"]]
			)
		)
		let sync = SyncMockRepository(result: .loaded(anyPushSuccessResponse(results: [failedResult])))
		let sut = makeSUT(sync: sync)

		let result = try await sut.createTransaction(request: anyCreateTransactionRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == 422)
		#expect(error.message == "The selected account or category is invalid.")
	}

	@Test(arguments: [401, 404, 500])
	func createTransaction_whenSyncThrowsErrorResponse_returnsErrorState(statusCode: Int) async throws {
		let expectedError = ErrorResponse(success: false, statusCode: statusCode, message: "Request failed", errors: nil)
		let sync = SyncMockRepository(result: .error(expectedError))
		let sut = makeSUT(sync: sync)

		let result = try await sut.createTransaction(request: anyCreateTransactionRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == statusCode)
		#expect(error.message == "Request failed")
	}

	@Test func createTransaction_whenSyncThrowsGenericError_returnsErrorState() async throws {
		let dummyError = NSError(domain: "TestError", code: 999)
		let sync = SyncMockRepository(result: .error(dummyError))
		let sut = makeSUT(sync: sync)

		let result = try await sut.createTransaction(request: anyCreateTransactionRequest())

		guard case .error(let error as NSError) = result else {
			Issue.record("Expected .error(NSError)")
			return
		}
		#expect(error.domain == "TestError")
		#expect(error.code == 999)
	}

	// MARK: - Helpers

	// `TransactionDefaultRepository` is a struct (per the codebase's Repository convention), so
	// there's no reference to leak — `trackForMemoryLeak` doesn't apply here.
	private func makeSUT(
		remote: TransactionMockRemoteDataSource = TransactionMockRemoteDataSource(),
		sync: SyncMockRepository = SyncMockRepository()
	) -> TransactionDefaultRepository {
		TransactionDefaultRepository(remote: remote, sync: sync)
	}
}
