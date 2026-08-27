//
//  UserCategoryMockRepository.swift
//  finance-test-iosTests
//

@testable import finance_test_ios

/// Test double for `UserCategoryRepository`, distinct from the app target's
/// `UserCategoryMockRepository` (which stands in for the real backend with a fixed response).
/// This one lets each test configure an arbitrary `RequestState` result and records invocations
/// for assertions.
final class UserCategoryMockRepository: UserCategoryRepository {

	enum Invocation: Equatable {
		case getUserCategories
		case createUserCategory(UserCategory.Request.CreateUserCategory)
	}

	private(set) var invocations: [Invocation] = []

	private let result: RequestState<GeneralResponse<[Sync.Response.UserCategoryItem]>>
	private let createResult: RequestState<GeneralResponse<Sync.Response.UserCategoryItem>>

	init(
		result: RequestState<GeneralResponse<[Sync.Response.UserCategoryItem]>> = .idle,
		createResult: RequestState<GeneralResponse<Sync.Response.UserCategoryItem>> = .idle
	) {
		self.result = result
		self.createResult = createResult
	}

	func getUserCategories() async throws -> RequestState<GeneralResponse<[Sync.Response.UserCategoryItem]>> {
		invocations.append(.getUserCategories)
		return result
	}

	func createUserCategory(
		request: UserCategory.Request.CreateUserCategory
	) async throws -> RequestState<GeneralResponse<Sync.Response.UserCategoryItem>> {
		invocations.append(.createUserCategory(request))
		return createResult
	}
}
