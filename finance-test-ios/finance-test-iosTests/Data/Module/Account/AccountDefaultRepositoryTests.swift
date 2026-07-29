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

	// MARK: - Helpers

	private func makeSUT(
		remote: AccountMockRemoteDataSource = AccountMockRemoteDataSource()
	) -> AccountDefaultRepository {
		AccountDefaultRepository(remote: remote)
	}
}
