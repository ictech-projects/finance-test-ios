//
//  SyncDefaultRepositoryTests.swift
//  finance-test-iosTests
//

import Foundation
import Testing
@testable import finance_test_ios

@Suite("SyncDefaultRepository")
struct SyncDefaultRepositoryTests {

	// MARK: - Tests

	@Test func push_callsRemoteWithCorrectRequest() async throws {
		let remote = SyncMockRemoteDataSource(pushResult: .success(anyPushSuccessResponse()))
		let sut = makeSUT(remote: remote)

		_ = try await sut.push(request: anyPushRequest())

		#expect(remote.invocations == [.push(anyPushRequest())])
	}

	@Test(arguments: [0, 1, 2])
	func push_withVaryingResultCounts_returnsMatchingResults(resultCount: Int) async throws {
		let results = (0..<resultCount).map { anyChangeResult(clientChangeId: "c\($0)", id: "id\($0)") }
		let remote = SyncMockRemoteDataSource(pushResult: .success(anyPushSuccessResponse(results: results)))
		let sut = makeSUT(remote: remote)

		let result = try await sut.push(request: anyPushRequest())

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.data?.results?.count == resultCount)
	}

	@Test func push_success_returnsExpectedData() async throws {
		let response = anyPushSuccessResponse()
		let remote = SyncMockRemoteDataSource(pushResult: .success(response))
		let sut = makeSUT(remote: remote)

		let result = try await sut.push(request: anyPushRequest())

		guard case .loaded(let loadedResponse) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(loadedResponse.success == true)
		#expect(loadedResponse.statusCode == 200)
		#expect(loadedResponse.data == response.data)
	}

	@Test(arguments: [401, 404, 500])
	func push_whenThrowsErrorResponse_returnsErrorState(statusCode: Int) async throws {
		let expectedError = ErrorResponse(success: false, statusCode: statusCode, message: "Request failed", errors: nil)
		let remote = SyncMockRemoteDataSource(pushResult: .failure(expectedError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.push(request: anyPushRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == statusCode)
		#expect(error.message == "Request failed")
	}

	@Test func push_whenThrowsGenericError_returnsErrorState() async throws {
		let dummyError = NSError(domain: "TestError", code: 999)
		let remote = SyncMockRemoteDataSource(pushResult: .failure(dummyError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.push(request: anyPushRequest())

		guard case .error(let error as NSError) = result else {
			Issue.record("Expected .error(NSError)")
			return
		}
		#expect(error.domain == "TestError")
		#expect(error.code == 999)
	}

	// MARK: - Helpers

	private func makeSUT(
		remote: SyncMockRemoteDataSource = SyncMockRemoteDataSource()
	) -> SyncDefaultRepository {
		SyncDefaultRepository(remote: remote)
	}
}
