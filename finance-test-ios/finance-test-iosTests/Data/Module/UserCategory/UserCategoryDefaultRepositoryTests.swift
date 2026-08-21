//
//  UserCategoryDefaultRepositoryTests.swift
//  finance-test-iosTests
//

import Foundation
import Testing
@testable import finance_test_ios

@Suite("UserCategoryDefaultRepository")
struct UserCategoryDefaultRepositoryTests {

	// MARK: - getUserCategories

	@Test func getUserCategories_callsSyncPull() async throws {
		let sync = SyncMockRepository(pullResult: .loaded(anyPullSuccessResponse()))
		let sut = makeSUT(sync: sync)

		_ = try await sut.getUserCategories()

		#expect(sync.invocations == [.pull(anyPullRequest())])
	}

	@Test(arguments: [0, 1, 2])
	func getUserCategories_withVaryingItemCounts_returnsMatchingList(itemCount: Int) async throws {
		let items = (0..<itemCount).map { anyUserCategoryItem(id: "\($0)") }
		let sync = SyncMockRepository(pullResult: .loaded(anyPullSuccessResponse(userCategories: items)))
		let sut = makeSUT(sync: sync)

		let result = try await sut.getUserCategories()

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.data?.count == itemCount)
	}

	@Test func getUserCategories_success_returnsExpectedData() async throws {
		let response = anyPullSuccessResponse()
		let sync = SyncMockRepository(pullResult: .loaded(response))
		let sut = makeSUT(sync: sync)

		let result = try await sut.getUserCategories()

		guard case .loaded(let loadedResponse) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(loadedResponse.data == response.data?.userCategories)
	}

	@Test(arguments: [401, 404, 500])
	func getUserCategories_whenThrowsErrorResponse_returnsErrorState(statusCode: Int) async throws {
		let expectedError = ErrorResponse(success: false, statusCode: statusCode, message: "Request failed", errors: nil)
		let sync = SyncMockRepository(pullResult: .error(expectedError))
		let sut = makeSUT(sync: sync)

		let result = try await sut.getUserCategories()

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == statusCode)
	}

	// MARK: - createUserCategory

	// There is no `POST /user-categories` — a create is submitted as a single-item `/sync/push`
	// batch, mirroring `TransactionDefaultRepositoryTests.createTransaction`.

	@Test func createUserCategory_callsSyncWithCorrectChange() async throws {
		let sync = SyncMockRepository(result: .loaded(anyPushSuccessResponse(results: [anyAppliedUserCategoryChangeResult()])))
		let sut = makeSUT(sync: sync)

		_ = try await sut.createUserCategory(request: anyCreateUserCategoryRequest())

		guard sync.invocations.count == 1, case .push(let pushRequest) = sync.invocations[0] else {
			Issue.record("Expected exactly one push invocation but got \(sync.invocations)")
			return
		}
		let change = try #require(pushRequest.changes.first)
		#expect(pushRequest.changes.count == 1)
		#expect(change.entity == "user_category")
		#expect(change.op == "create")
		let decodedData = try change.data?.decoded(as: UserCategory.Request.CreateUserCategory.self)
		#expect(decodedData == anyCreateUserCategoryRequest())
	}

	@Test func createUserCategory_success_returnsCreatedItem() async throws {
		let item = anyUserCategoryItem(id: "01K3UT0000000000000000UT02", name: "Freelance", type: .income)
		let sync = SyncMockRepository(
			result: .loaded(anyPushSuccessResponse(results: [anyAppliedUserCategoryChangeResult(id: item.id, item: item)]))
		)
		let sut = makeSUT(sync: sync)

		let result = try await sut.createUserCategory(request: anyCreateUserCategoryRequest())

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.data == item)
	}

	@Test func createUserCategory_whenChangeFails_returnsErrorState() async throws {
		let failedResult = Sync.Response.ChangeResult(
			clientChangeId: "c1", id: "01K3UT0000000000000000UT02", entity: "user_category", status: "failed",
			record: nil,
			error: Sync.Response.ChangeError(message: "Invalid category type.", errors: ["type": ["invalid"]])
		)
		let sync = SyncMockRepository(result: .loaded(anyPushSuccessResponse(results: [failedResult])))
		let sut = makeSUT(sync: sync)

		let result = try await sut.createUserCategory(request: anyCreateUserCategoryRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == 422)
		#expect(error.message == "Invalid category type.")
	}

	@Test(arguments: [401, 404, 500])
	func createUserCategory_whenSyncThrowsErrorResponse_returnsErrorState(statusCode: Int) async throws {
		let expectedError = ErrorResponse(success: false, statusCode: statusCode, message: "Request failed", errors: nil)
		let sync = SyncMockRepository(result: .error(expectedError))
		let sut = makeSUT(sync: sync)

		let result = try await sut.createUserCategory(request: anyCreateUserCategoryRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == statusCode)
	}

	// MARK: - Helpers

	// `UserCategoryDefaultRepository` is a struct (per the codebase's Repository convention), so
	// there's no reference to leak — `trackForMemoryLeak` doesn't apply here.
	private func makeSUT(sync: SyncMockRepository = SyncMockRepository()) -> UserCategoryDefaultRepository {
		UserCategoryDefaultRepository(sync: sync)
	}
}
