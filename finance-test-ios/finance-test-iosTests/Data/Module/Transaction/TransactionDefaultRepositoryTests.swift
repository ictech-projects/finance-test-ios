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

	// MARK: - Helpers

	// `TransactionDefaultRepository` is a struct (per the codebase's Repository convention), so
	// there's no reference to leak — `trackForMemoryLeak` doesn't apply here.
	private func makeSUT(
		remote: TransactionMockRemoteDataSource = TransactionMockRemoteDataSource()
	) -> TransactionDefaultRepository {
		TransactionDefaultRepository(remote: remote)
	}
}
