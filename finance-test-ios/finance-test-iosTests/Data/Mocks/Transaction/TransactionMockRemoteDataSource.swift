//
//  TransactionMockRemoteDataSource.swift
//  finance-test-iosTests
//

@testable import finance_test_ios

final class TransactionMockRemoteDataSource: TransactionRemoteDataSource {

	enum Invocation: Equatable {
		case getTransactions(TransactionRecord.Request.GetTransactions)
	}

	private(set) var invocations: [Invocation] = []

	private let getTransactionsResult: Result<GeneralResponse<TransactionRecord.Response.TransactionList>, Error>

	init(
		getTransactionsResult: Result<GeneralResponse<TransactionRecord.Response.TransactionList>, Error> = .success(
			anyTransactionListSuccessResponse()
		)
	) {
		self.getTransactionsResult = getTransactionsResult
	}

	func getTransactions(
		request: TransactionRecord.Request.GetTransactions
	) async throws -> GeneralResponse<TransactionRecord.Response.TransactionList> {
		invocations.append(.getTransactions(request))
		return try getTransactionsResult.get()
	}
}

func anyTransactionItem(
	id: String = "01K3TX0000000000000000TX01",
	accountId: String = "01K3AC0000000000000000AC01",
	categoryId: String = "01K3CT0000000000000000CT01",
	type: TransactionType = .expense,
	amount: String = "42.50"
) -> TransactionRecord.Response.TransactionItem {
	TransactionRecord.Response.TransactionItem(
		id: id, userId: "01K3US0000000000000000US01",
		accountId: accountId, categoryId: categoryId,
		currencyId: "usd", exchangeRateToAnchor: "1",
		type: type, amount: amount, description: "Lunch at the Bistro",
		transactionDate: "2026-07-27", createdAt: nil, updatedAt: nil, deletedAt: nil
	)
}

func anyGetTransactionsRequest() -> TransactionRecord.Request.GetTransactions {
	TransactionRecord.Request.GetTransactions(since: nil)
}

func anyCreateTransactionRequest(
	accountId: String = "01K3AC0000000000000000AC01",
	categoryId: String = "01K3CT0000000000000000CT01",
	type: TransactionType = .expense,
	amount: String = "42.50",
	exchangeRateToAnchor: String = "1",
	description: String? = "Lunch at the Bistro",
	transactionDate: String = "2026-07-27"
) -> TransactionRecord.Request.CreateTransaction {
	TransactionRecord.Request.CreateTransaction(
		accountId: accountId, categoryId: categoryId, type: type, amount: amount,
		exchangeRateToAnchor: exchangeRateToAnchor, description: description, transactionDate: transactionDate
	)
}

func anyAppliedTransactionChangeResult(
	clientChangeId: String? = "c1",
	id: String? = "01K3TX0000000000000000TX01",
	item: TransactionRecord.Response.TransactionItem = anyTransactionItem()
) -> Sync.Response.ChangeResult {
	Sync.Response.ChangeResult(
		clientChangeId: clientChangeId, id: id, entity: "transaction", status: "applied",
		record: try? JSONValue(encoding: item), error: nil
	)
}

func anyTransactionListSuccessResponse(
	items: [TransactionRecord.Response.TransactionItem] = [anyTransactionItem()]
) -> GeneralResponse<TransactionRecord.Response.TransactionList> {
	GeneralResponse(
		success: true,
		statusCode: 200,
		message: "Transactions fetched.",
		data: TransactionRecord.Response.TransactionList(items: items, serverTime: nil)
	)
}
