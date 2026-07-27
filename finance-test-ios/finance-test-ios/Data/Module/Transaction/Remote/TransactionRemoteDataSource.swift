//
//  TransactionRemoteDataSource.swift
//  finance-test-ios
//

import Foundation

protocol TransactionRemoteDataSource {
	func getTransactions(
		request: TransactionRecord.Request.GetTransactions
	) async throws -> GeneralResponse<TransactionRecord.Response.TransactionList>
}
