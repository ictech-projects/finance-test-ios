//
//  TransactionRepository.swift
//  finance-test-ios
//

protocol TransactionRepository {
	func getTransactions(
		request: TransactionRecord.Request.GetTransactions
	) async throws -> RequestState<GeneralResponse<TransactionRecord.Response.TransactionList>>

	func createTransaction(
		request: TransactionRecord.Request.CreateTransaction
	) async throws -> RequestState<GeneralResponse<TransactionRecord.Response.TransactionItem>>
}
