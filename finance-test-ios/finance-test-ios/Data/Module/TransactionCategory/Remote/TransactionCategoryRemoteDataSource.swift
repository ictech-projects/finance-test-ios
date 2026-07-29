//
//  TransactionCategoryRemoteDataSource.swift
//  finance-test-ios
//

import Foundation

protocol TransactionCategoryRemoteDataSource {
	func getCategories(
		request: TransactionCategory.Request.GetCategories
	) async throws -> GeneralResponse<TransactionCategory.Response.CategoryList>
}
