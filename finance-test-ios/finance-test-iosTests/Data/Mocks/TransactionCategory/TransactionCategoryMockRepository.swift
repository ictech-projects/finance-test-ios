//
//  TransactionCategoryMockRepository.swift
//  finance-test-iosTests
//

@testable import finance_test_ios

/// Test double for `TransactionCategoryRepository`, distinct from the app target's
/// `TransactionCategoryMockRepository` (which stands in for the real backend until the auth
/// module lands). This one lets each test configure an arbitrary `RequestState` result and
/// records invocations for assertions.
final class TransactionCategoryMockRepository: TransactionCategoryRepository {

	enum Invocation: Equatable {
		case getCategories(TransactionCategory.Request.GetCategories)
	}

	private(set) var invocations: [Invocation] = []

	private let result: RequestState<GeneralResponse<TransactionCategory.Response.CategoryList>>

	init(result: RequestState<GeneralResponse<TransactionCategory.Response.CategoryList>> = .idle) {
		self.result = result
	}

	func getCategories(
		request: TransactionCategory.Request.GetCategories
	) async throws -> RequestState<GeneralResponse<TransactionCategory.Response.CategoryList>> {
		invocations.append(.getCategories(request))
		return result
	}
}
