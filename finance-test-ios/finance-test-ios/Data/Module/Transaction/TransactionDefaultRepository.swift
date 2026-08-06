//
//  TransactionDefaultRepository.swift
//  finance-test-ios
//

import Foundation

struct TransactionDefaultRepository: TransactionRepository {

	private let remote: any TransactionRemoteDataSource
	private let sync: any SyncRepository

	init(
		remote: some TransactionRemoteDataSource = TransactionDefaultRemoteDataSource(),
		sync: some SyncRepository = SyncDefaultRepository()
	) {
		self.remote = remote
		self.sync = sync
	}

	func getTransactions(
		request: TransactionRecord.Request.GetTransactions
	) async throws -> RequestState<GeneralResponse<TransactionRecord.Response.TransactionList>> {
		await execute { try await remote.getTransactions(request: request) }
	}

	/// There is no `POST /transactions` — creation goes through the shared `/sync/push` write path.
	/// A single-item batch is submitted, and its `applied`/`failed` result is unwrapped back into
	/// the same `TransactionItem` shape `getTransactions` returns.
	func createTransaction(
		request: TransactionRecord.Request.CreateTransaction
	) async throws -> RequestState<GeneralResponse<TransactionRecord.Response.TransactionItem>> {
		let change = Sync.Request.Change(
			clientChangeId: ULIDGenerator.generate(),
			entity: "transaction",
			op: "create",
			id: ULIDGenerator.generate(),
			data: try? JSONValue(encoding: request)
		)

		let pushState = try await sync.push(request: Sync.Request.Push(changes: [change]))

		switch pushState {
		case .loaded(let response):
			return await execute { try Self.transactionItem(fromFirstResultOf: response) }
		case .error(let error):
			return .error(error)
		default:
			return .idle
		}
	}

	private static func transactionItem(
		fromFirstResultOf response: GeneralResponse<Sync.Response.PushResult>
	) throws -> GeneralResponse<TransactionRecord.Response.TransactionItem> {
		guard let result = response.data?.results?.first else {
			throw ErrorResponse(
				success: false, statusCode: -1,
				message: "No result returned for transaction creation.", errors: nil
			)
		}

		guard result.status == "applied", let record = result.record else {
			throw ErrorResponse(
				success: false, statusCode: 422,
				message: result.error?.message ?? "Failed to create transaction.", errors: nil
			)
		}

		let item = try record.decoded(as: TransactionRecord.Response.TransactionItem.self)

		return GeneralResponse(
			success: response.success,
			statusCode: response.statusCode,
			message: response.message,
			data: item
		)
	}
}
