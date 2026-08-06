//
//  TransactionCategoryDefaultRepository.swift
//  finance-test-ios
//

import Foundation

struct TransactionCategoryDefaultRepository: TransactionCategoryRepository {

	private let remote: any TransactionCategoryRemoteDataSource

	init(remote: some TransactionCategoryRemoteDataSource = TransactionCategoryDefaultRemoteDataSource()) {
		self.remote = remote
	}

	func getCategories(
		request: TransactionCategory.Request.GetCategories
	) async throws -> RequestState<GeneralResponse<TransactionCategory.Response.CategoryList>> {
		await execute { try await remote.getCategories(request: request) }
	}
}
