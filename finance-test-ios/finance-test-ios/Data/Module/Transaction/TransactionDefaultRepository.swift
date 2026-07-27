//
//  TransactionDefaultRepository.swift
//  finance-test-ios
//

import Foundation

struct TransactionDefaultRepository: TransactionRepository {

	private let remote: any TransactionRemoteDataSource

	init(remote: some TransactionRemoteDataSource = TransactionDefaultRemoteDataSource()) {
		self.remote = remote
	}

	func getTransactions(
		request: TransactionRecord.Request.GetTransactions
	) async throws -> RequestState<GeneralResponse<TransactionRecord.Response.TransactionList>> {
		await execute { try await remote.getTransactions(request: request) }
	}
}
