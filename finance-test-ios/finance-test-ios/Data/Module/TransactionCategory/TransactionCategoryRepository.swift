//
//  TransactionCategoryRepository.swift
//  finance-test-ios
//

protocol TransactionCategoryRepository {
	func getCategories(
		request: TransactionCategory.Request.GetCategories
	) async throws -> RequestState<GeneralResponse<TransactionCategory.Response.CategoryList>>
}
