//
//  TransactionMockRepository.swift
//  finance-test-ios
//

import Foundation

/// Stands in for `TransactionDefaultRepository` until the auth module exists and `/transactions`
/// can actually be called. Swap the default in consuming ViewModels to `TransactionDefaultRepository()`
/// once a valid access token is available.
struct TransactionMockRepository: TransactionRepository {

	func getTransactions(
		request: TransactionRecord.Request.GetTransactions
	) async -> RequestState<GeneralResponse<TransactionRecord.Response.TransactionList>> {
		try? await Task.sleep(nanoseconds: 400_000_000)

		return .loaded(
			GeneralResponse(
				success: true,
				statusCode: 200,
				message: "Transactions fetched.",
				data: TransactionRecord.Response.TransactionList(
					items: TransactionRecord.Response.TransactionItem.mocks,
					serverTime: nil
				)
			)
		)
	}
}
