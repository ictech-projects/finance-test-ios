//
//  TransactionCategoryDefaultRemoteDataSource.swift
//  finance-test-ios
//

import Moya

struct TransactionCategoryDefaultRemoteDataSource: TransactionCategoryRemoteDataSource {

	private let provider: MoyaProvider<TransactionCategoryTargetType>

	init(provider: MoyaProvider<TransactionCategoryTargetType> = .defaultProvider()) {
		self.provider = provider
	}

	func getCategories(
		request: TransactionCategory.Request.GetCategories
	) async throws -> GeneralResponse<TransactionCategory.Response.CategoryList> {
		try await provider.request(
			.getCategories(request),
			model: GeneralResponse<TransactionCategory.Response.CategoryList>.self
		)
	}
}
