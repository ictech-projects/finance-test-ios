//
//  AccountDefaultRepository.swift
//  finance-test-ios
//

import Foundation

struct AccountDefaultRepository: AccountRepository {

	private let remote: any AccountRemoteDataSource
	private let sync: any SyncRepository

	init(
		remote: some AccountRemoteDataSource = AccountDefaultRemoteDataSource(),
		sync: some SyncRepository = SyncDefaultRepository()
	) {
		self.remote = remote
		self.sync = sync
	}

	func getAccounts(
		request: Account.Request.GetAccounts
	) async throws -> RequestState<GeneralResponse<Account.Response.AccountList>> {
		await execute { try await remote.getAccounts(request: request) }
	}

	func createAccount(
		request: Account.Request.CreateAccount
	) async throws -> RequestState<GeneralResponse<Account.Response.AccountItem>> {
		await execute { try await remote.createAccount(request: request) }
	}

	/// There is no `PATCH /accounts/{id}` — an update is submitted as an `account`/`update` change
	/// through the shared `/sync/push` write path instead, mirroring
	/// `UserCurrencyDefaultRepository.updateUserCurrency`'s push-and-unwrap approach. `id` is the
	/// existing account's id (not a freshly generated one) — only `client_change_id` is generated
	/// fresh per call.
	func updateAccount(
		id: String,
		request: Account.Request.UpdateAccount
	) async throws -> RequestState<GeneralResponse<Account.Response.AccountItem>> {
		let change = Sync.Request.Change(
			clientChangeId: ULIDGenerator.generate(),
			entity: "account",
			op: "update",
			id: id,
			data: try? JSONValue(encoding: request)
		)

		let pushState = try await sync.push(request: Sync.Request.Push(changes: [change]))

		switch pushState {
		case .loaded(let response):
			return await execute { try Self.accountItem(fromFirstResultOf: response) }
		case .error(let error):
			return .error(error)
		default:
			return .idle
		}
	}

	private static func accountItem(
		fromFirstResultOf response: GeneralResponse<Sync.Response.PushResult>
	) throws -> GeneralResponse<Account.Response.AccountItem> {
		guard let result = response.data?.results?.first else {
			throw ErrorResponse(
				success: false, statusCode: -1,
				message: "No result returned for account update.", errors: nil
			)
		}

		guard result.status == "applied", let record = result.record else {
			throw ErrorResponse(
				success: false, statusCode: 422,
				message: result.error?.message ?? "Failed to update account.", errors: nil
			)
		}

		let item = try record.decoded(as: Account.Response.AccountItem.self)

		return GeneralResponse(
			success: response.success,
			statusCode: response.statusCode,
			message: response.message,
			data: item
		)
	}
}
