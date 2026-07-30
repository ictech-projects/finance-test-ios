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

	func createTransaction(
		request: TransactionRecord.Request.CreateTransaction
	) async -> RequestState<GeneralResponse<TransactionRecord.Response.TransactionItem>> {
		try? await Task.sleep(nanoseconds: 400_000_000)

		let now = ISO8601DateFormatter().string(from: Date())

		return .loaded(
			GeneralResponse(
				success: true,
				statusCode: 200,
				message: "Transaction created.",
				data: TransactionRecord.Response.TransactionItem(
					id: ULIDGenerator.generate(),
					userId: "01K3US0000000000000000US01",
					accountId: request.accountId,
					categoryId: request.categoryId,
					currencyId: nil,
					exchangeRateToAnchor: request.exchangeRateToAnchor,
					type: request.type,
					amount: request.amount,
					description: request.description,
					transactionDate: request.transactionDate,
					createdAt: now,
					updatedAt: now,
					deletedAt: nil
				)
			)
		)
	}
}
