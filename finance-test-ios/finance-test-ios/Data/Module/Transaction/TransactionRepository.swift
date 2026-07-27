//
//  TransactionRepository.swift
//  finance-test-ios
//

protocol TransactionRepository {
	func getTransactions(
		request: TransactionRecord.Request.GetTransactions
	) async throws -> RequestState<GeneralResponse<TransactionRecord.Response.TransactionList>>
}
