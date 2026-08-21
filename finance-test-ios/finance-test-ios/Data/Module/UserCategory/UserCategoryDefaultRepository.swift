//
//  UserCategoryDefaultRepository.swift
//  finance-test-ios
//

import Foundation

/// 100% Sync-backed — there is no dedicated REST resource for user categories, so unlike most
/// repositories this one holds no `RemoteDataSource` at all, only the shared `SyncRepository`.
struct UserCategoryDefaultRepository: UserCategoryRepository {

	private let sync: any SyncRepository

	init(sync: some SyncRepository = SyncDefaultRepository()) {
		self.sync = sync
	}

	/// Global categories are readable via `GET /categories`, but user-owned categories only exist
	/// on `/sync/pull`'s omnibus payload — this projects out just the `user_categories` slice.
	func getUserCategories() async throws -> RequestState<GeneralResponse<[Sync.Response.UserCategoryItem]>> {
		let pullState = try await sync.pull(request: Sync.Request.Pull(since: nil, limit: nil))

		switch pullState {
		case .loaded(let response):
			return .loaded(
				GeneralResponse(
					success: response.success,
					statusCode: response.statusCode,
					message: response.message,
					data: response.data?.userCategories ?? []
				)
			)
		case .error(let error):
			return .error(error)
		default:
			return .idle
		}
	}

	/// There is no `POST /user-categories` — a create is submitted as a `user_category`/`create`
	/// change through the shared `/sync/push` write path, mirroring
	/// `TransactionDefaultRepository.createTransaction`'s push-and-unwrap approach. `id` is a
	/// freshly client-generated id (unlike an update, where `id` is the existing record's id).
	func createUserCategory(
		request: UserCategory.Request.CreateUserCategory
	) async throws -> RequestState<GeneralResponse<Sync.Response.UserCategoryItem>> {
		let change = Sync.Request.Change(
			clientChangeId: ULIDGenerator.generate(),
			entity: "user_category",
			op: "create",
			id: ULIDGenerator.generate(),
			data: try? JSONValue(encoding: request)
		)

		let pushState = try await sync.push(request: Sync.Request.Push(changes: [change]))

		switch pushState {
		case .loaded(let response):
			return await execute { try Self.userCategoryItem(fromFirstResultOf: response) }
		case .error(let error):
			return .error(error)
		default:
			return .idle
		}
	}

	private static func userCategoryItem(
		fromFirstResultOf response: GeneralResponse<Sync.Response.PushResult>
	) throws -> GeneralResponse<Sync.Response.UserCategoryItem> {
		guard let result = response.data?.results?.first else {
			throw ErrorResponse(
				success: false, statusCode: -1,
				message: "No result returned for user category creation.", errors: nil
			)
		}

		guard result.status == "applied", let record = result.record else {
			throw ErrorResponse(
				success: false, statusCode: 422,
				message: result.error?.message ?? "Failed to create category.", errors: nil
			)
		}

		let item = try record.decoded(as: Sync.Response.UserCategoryItem.self)

		return GeneralResponse(
			success: response.success,
			statusCode: response.statusCode,
			message: response.message,
			data: item
		)
	}
}
