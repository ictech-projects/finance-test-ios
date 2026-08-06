//
//  TransactionCategoryMockRepository.swift
//  finance-test-ios
//

import Foundation

/// Stands in for `TransactionCategoryDefaultRepository` until the auth module exists and
/// `/categories` can actually be called. Swap the default in consuming ViewModels to
/// `TransactionCategoryDefaultRepository()` once a valid access token is available.
struct TransactionCategoryMockRepository: TransactionCategoryRepository {

	func getCategories(
		request: TransactionCategory.Request.GetCategories
	) async -> RequestState<GeneralResponse<TransactionCategory.Response.CategoryList>> {
		try? await Task.sleep(nanoseconds: 400_000_000)

		let items = TransactionCategory.Response.CategoryItem.mocks.filter { item in
			guard let type = request.type else { return true }
			return item.type == type
		}

		return .loaded(
			GeneralResponse(
				success: true,
				statusCode: 200,
				message: "Categories fetched.",
				data: TransactionCategory.Response.CategoryList(items: items, serverTime: nil)
			)
		)
	}
}
