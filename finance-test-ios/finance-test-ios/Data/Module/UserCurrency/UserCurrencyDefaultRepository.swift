//
//  UserCurrencyDefaultRepository.swift
//  finance-test-ios
//

import Foundation

struct UserCurrencyDefaultRepository: UserCurrencyRepository {

	private let remote: any UserCurrencyRemoteDataSource
	private let sync: any SyncRepository

	init(
		remoteDataSource: some UserCurrencyRemoteDataSource = UserCurrencyDefaultRemoteDataSource(),
		sync: some SyncRepository = SyncDefaultRepository()
	) {
		self.remote = remoteDataSource
		self.sync = sync
	}

	func getUserCurrencies(
		request: UserCurrency.Request.GetUserCurrencies
	) async throws -> RequestState<GeneralResponse<UserCurrency.Response.UserCurrencyList>> {
		await execute { try await remote.getUserCurrencies(request: request) }
	}

	func createUserCurrency(
		request: UserCurrency.Request.CreateUserCurrency
	) async throws -> RequestState<GeneralResponse<UserCurrency.Response.UserCurrencyItem>> {
		await execute { try await remote.createUserCurrency(request: request) }
	}

	/// There is no `PATCH /user-currencies/{id}` — an update is submitted as a `user_currency`/
	/// `update` change through the shared `/sync/push` write path instead, mirroring
	/// `TransactionDefaultRepository.createTransaction`'s push-and-unwrap approach. `id` is the
	/// existing user currency's id (not a freshly generated one) — only `client_change_id` is
	/// generated fresh per call.
	func updateUserCurrency(
		id: String,
		request: UserCurrency.Request.UpdateUserCurrency
	) async throws -> RequestState<GeneralResponse<UserCurrency.Response.UserCurrencyItem>> {
		let change = Sync.Request.Change(
			clientChangeId: ULIDGenerator.generate(),
			entity: "user_currency",
			op: "update",
			id: id,
			data: try? JSONValue(encoding: request)
		)

		let pushState = try await sync.push(request: Sync.Request.Push(changes: [change]))

		switch pushState {
		case .loaded(let response):
			return await execute { try Self.userCurrencyItem(fromFirstResultOf: response) }
		case .error(let error):
			return .error(error)
		default:
			return .idle
		}
	}

	private static func userCurrencyItem(
		fromFirstResultOf response: GeneralResponse<Sync.Response.PushResult>
	) throws -> GeneralResponse<UserCurrency.Response.UserCurrencyItem> {
		guard let result = response.data?.results?.first else {
			throw ErrorResponse(
				success: false, statusCode: -1,
				message: "No result returned for user currency update.", errors: nil
			)
		}

		guard result.status == "applied", let record = result.record else {
			throw ErrorResponse(
				success: false, statusCode: 422,
				message: result.error?.message ?? "Failed to update user currency.", errors: nil
			)
		}

		let item = try record.decoded(as: UserCurrency.Response.UserCurrencyItem.self)

		return GeneralResponse(
			success: response.success,
			statusCode: response.statusCode,
			message: response.message,
			data: item
		)
	}
}
