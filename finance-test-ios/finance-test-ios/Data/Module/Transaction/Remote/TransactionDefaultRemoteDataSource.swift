//
//  TransactionDefaultRemoteDataSource.swift
//  finance-test-ios
//

import Moya

struct TransactionDefaultRemoteDataSource: TransactionRemoteDataSource {

	private let provider: MoyaProvider<TransactionTargetType>

	init(provider: MoyaProvider<TransactionTargetType> = .defaultProvider()) {
		self.provider = provider
	}

	func getTransactions(
		request: TransactionRecord.Request.GetTransactions
	) async throws -> GeneralResponse<TransactionRecord.Response.TransactionList> {
		try await provider.request(
			.getTransactions(request),
			model: GeneralResponse<TransactionRecord.Response.TransactionList>.self
		)
	}
}
