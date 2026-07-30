//
//  TransactionMockRepository.swift
//  finance-test-iosTests
//

@testable import finance_test_ios

/// Test double for `TransactionRepository`, distinct from the app target's `TransactionMockRepository`
/// (which stands in for the real backend until the auth module lands). This one lets each test
/// configure an arbitrary `RequestState` result and records invocations for assertions.
final class TransactionMockRepository: TransactionRepository {

	enum Invocation: Equatable {
		case getTransactions(TransactionRecord.Request.GetTransactions)
		case createTransaction(TransactionRecord.Request.CreateTransaction)
	}

	private(set) var invocations: [Invocation] = []

	private let result: RequestState<GeneralResponse<TransactionRecord.Response.TransactionList>>
	private let createTransactionResult: RequestState<GeneralResponse<TransactionRecord.Response.TransactionItem>>

	init(
		result: RequestState<GeneralResponse<TransactionRecord.Response.TransactionList>> = .idle,
		createTransactionResult: RequestState<GeneralResponse<TransactionRecord.Response.TransactionItem>> = .idle
	) {
		self.result = result
		self.createTransactionResult = createTransactionResult
	}

	func getTransactions(
		request: TransactionRecord.Request.GetTransactions
	) async throws -> RequestState<GeneralResponse<TransactionRecord.Response.TransactionList>> {
		invocations.append(.getTransactions(request))
		return result
	}

	func createTransaction(
		request: TransactionRecord.Request.CreateTransaction
	) async throws -> RequestState<GeneralResponse<TransactionRecord.Response.TransactionItem>> {
		invocations.append(.createTransaction(request))
		return createTransactionResult
	}
}
