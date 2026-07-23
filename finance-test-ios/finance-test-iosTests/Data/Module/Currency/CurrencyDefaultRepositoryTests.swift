//
//  CurrencyDefaultRepositoryTests.swift
//  finance-test-iosTests
//

import Foundation
import Testing
@testable import finance_test_ios

@Suite("CurrencyDefaultRepository")
struct CurrencyDefaultRepositoryTests {

	// MARK: - Tests

	@Test func getCurrencies_callsRemoteWithCorrectRequest() async throws {
		let remote = CurrencyMockRemoteDataSource(getCurrenciesResult: .success(anyCurrencyListSuccessResponse()))
		let sut = makeSUT(remote: remote)

		_ = try await sut.getCurrencies(request: anyGetCurrenciesRequest())

		#expect(remote.invocations == [.getCurrencies(anyGetCurrenciesRequest())])
	}

	@Test(arguments: [0, 1, 2])
	func getCurrencies_withVaryingItemCounts_returnsMatchingList(itemCount: Int) async throws {
		let items = (0..<itemCount).map { anyCurrencyItem(id: "\($0)") }
		let remote = CurrencyMockRemoteDataSource(
			getCurrenciesResult: .success(anyCurrencyListSuccessResponse(items: items))
		)
		let sut = makeSUT(remote: remote)

		let result = try await sut.getCurrencies(request: anyGetCurrenciesRequest())

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.data?.items?.count == itemCount)
	}

	@Test func getCurrencies_success_returnsExpectedData() async throws {
		let response = anyCurrencyListSuccessResponse()
		let remote = CurrencyMockRemoteDataSource(getCurrenciesResult: .success(response))
		let sut = makeSUT(remote: remote)

		let result = try await sut.getCurrencies(request: anyGetCurrenciesRequest())

		guard case .loaded(let loadedResponse) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(loadedResponse.success == true)
		#expect(loadedResponse.statusCode == 200)
		#expect(loadedResponse.data == response.data)
	}

	@Test(arguments: [401, 404, 500])
	func getCurrencies_whenThrowsErrorResponse_returnsErrorState(statusCode: Int) async throws {
		let expectedError = ErrorResponse(success: false, statusCode: statusCode, message: "Request failed", errors: nil)
		let remote = CurrencyMockRemoteDataSource(getCurrenciesResult: .failure(expectedError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.getCurrencies(request: anyGetCurrenciesRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == statusCode)
		#expect(error.message == "Request failed")
	}

	@Test func getCurrencies_whenThrowsGenericError_returnsErrorState() async throws {
		let dummyError = NSError(domain: "TestError", code: 999)
		let remote = CurrencyMockRemoteDataSource(getCurrenciesResult: .failure(dummyError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.getCurrencies(request: anyGetCurrenciesRequest())

		guard case .error(let error as NSError) = result else {
			Issue.record("Expected .error(NSError)")
			return
		}
		#expect(error.domain == "TestError")
		#expect(error.code == 999)
	}

	// MARK: - Helpers

	// `CurrencyDefaultRepository` is a struct (per the codebase's Repository convention), so
	// there's no reference to leak — `trackForMemoryLeak` doesn't apply here.
	private func makeSUT(
		remote: CurrencyMockRemoteDataSource = CurrencyMockRemoteDataSource()
	) -> CurrencyDefaultRepository {
		CurrencyDefaultRepository(remote: remote)
	}
}
