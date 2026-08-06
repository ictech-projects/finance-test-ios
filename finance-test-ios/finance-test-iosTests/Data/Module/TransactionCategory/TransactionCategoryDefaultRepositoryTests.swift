//
//  TransactionCategoryDefaultRepositoryTests.swift
//  finance-test-iosTests
//

import Foundation
import Testing
@testable import finance_test_ios

@Suite("TransactionCategoryDefaultRepository")
struct TransactionCategoryDefaultRepositoryTests {

	// MARK: - Tests

	@Test func getCategories_callsRemoteWithCorrectRequest() async throws {
		let remote = TransactionCategoryMockRemoteDataSource(getCategoriesResult: .success(anyCategoryListSuccessResponse()))
		let sut = makeSUT(remote: remote)

		_ = try await sut.getCategories(request: anyGetCategoriesRequest())

		#expect(remote.invocations == [.getCategories(anyGetCategoriesRequest())])
	}

	@Test(arguments: [0, 1, 2])
	func getCategories_withVaryingItemCounts_returnsMatchingList(itemCount: Int) async throws {
		let items = (0..<itemCount).map { anyCategoryItem(id: "\($0)") }
		let remote = TransactionCategoryMockRemoteDataSource(
			getCategoriesResult: .success(anyCategoryListSuccessResponse(items: items))
		)
		let sut = makeSUT(remote: remote)

		let result = try await sut.getCategories(request: anyGetCategoriesRequest())

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.data?.items?.count == itemCount)
	}

	@Test func getCategories_success_returnsExpectedData() async throws {
		let response = anyCategoryListSuccessResponse()
		let remote = TransactionCategoryMockRemoteDataSource(getCategoriesResult: .success(response))
		let sut = makeSUT(remote: remote)

		let result = try await sut.getCategories(request: anyGetCategoriesRequest())

		guard case .loaded(let loadedResponse) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(loadedResponse.success == true)
		#expect(loadedResponse.statusCode == 200)
		#expect(loadedResponse.data == response.data)
	}

	@Test(arguments: [401, 404, 500])
	func getCategories_whenThrowsErrorResponse_returnsErrorState(statusCode: Int) async throws {
		let expectedError = ErrorResponse(success: false, statusCode: statusCode, message: "Request failed", errors: nil)
		let remote = TransactionCategoryMockRemoteDataSource(getCategoriesResult: .failure(expectedError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.getCategories(request: anyGetCategoriesRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == statusCode)
		#expect(error.message == "Request failed")
	}

	@Test func getCategories_whenThrowsGenericError_returnsErrorState() async throws {
		let dummyError = NSError(domain: "TestError", code: 999)
		let remote = TransactionCategoryMockRemoteDataSource(getCategoriesResult: .failure(dummyError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.getCategories(request: anyGetCategoriesRequest())

		guard case .error(let error as NSError) = result else {
			Issue.record("Expected .error(NSError)")
			return
		}
		#expect(error.domain == "TestError")
		#expect(error.code == 999)
	}

	// MARK: - Helpers

	private func makeSUT(
		remote: TransactionCategoryMockRemoteDataSource = TransactionCategoryMockRemoteDataSource()
	) -> TransactionCategoryDefaultRepository {
		TransactionCategoryDefaultRepository(remote: remote)
	}
}
