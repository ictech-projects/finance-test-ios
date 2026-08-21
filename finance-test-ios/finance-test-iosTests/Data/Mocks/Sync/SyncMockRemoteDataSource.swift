//
//  SyncMockRemoteDataSource.swift
//  finance-test-iosTests
//

@testable import finance_test_ios

final class SyncMockRemoteDataSource: SyncRemoteDataSource {

	enum Invocation: Equatable {
		case push(Sync.Request.Push)
		case pull(Sync.Request.Pull)
	}

	private(set) var invocations: [Invocation] = []

	private let pushResult: Result<GeneralResponse<Sync.Response.PushResult>, Error>
	private let pullResult: Result<GeneralResponse<Sync.Response.Pull>, Error>

	init(
		pushResult: Result<GeneralResponse<Sync.Response.PushResult>, Error> = .success(anyPushSuccessResponse()),
		pullResult: Result<GeneralResponse<Sync.Response.Pull>, Error> = .success(anyPullSuccessResponse())
	) {
		self.pushResult = pushResult
		self.pullResult = pullResult
	}

	func push(request: Sync.Request.Push) async throws -> GeneralResponse<Sync.Response.PushResult> {
		invocations.append(.push(request))
		return try pushResult.get()
	}

	func pull(request: Sync.Request.Pull) async throws -> GeneralResponse<Sync.Response.Pull> {
		invocations.append(.pull(request))
		return try pullResult.get()
	}
}

func anyChange(
	clientChangeId: String = "c1",
	entity: String = "transaction",
	op: String = "create",
	id: String = "01K3TX0000000000000000TX01",
	data: JSONValue? = .object(["amount": .string("42.50")])
) -> Sync.Request.Change {
	Sync.Request.Change(clientChangeId: clientChangeId, entity: entity, op: op, id: id, data: data)
}

func anyPushRequest(changes: [Sync.Request.Change] = [anyChange()]) -> Sync.Request.Push {
	Sync.Request.Push(changes: changes)
}

func anyChangeResult(
	clientChangeId: String? = "c1",
	id: String? = "01K3TX0000000000000000TX01",
	entity: String? = "transaction",
	status: String? = "applied",
	record: JSONValue? = .object(["id": .string("01K3TX0000000000000000TX01"), "amount": .string("42.50")]),
	error: Sync.Response.ChangeError? = nil
) -> Sync.Response.ChangeResult {
	Sync.Response.ChangeResult(
		clientChangeId: clientChangeId, id: id, entity: entity, status: status, record: record, error: error
	)
}

func anyPushSuccessResponse(
	results: [Sync.Response.ChangeResult] = [anyChangeResult()]
) -> GeneralResponse<Sync.Response.PushResult> {
	GeneralResponse(
		success: true,
		statusCode: 200,
		message: "Changes applied.",
		data: Sync.Response.PushResult(results: results, serverTime: nil)
	)
}

func anyPullRequest(since: String? = nil, limit: Int? = nil) -> Sync.Request.Pull {
	Sync.Request.Pull(since: since, limit: limit)
}

func anyUserCategoryItem(
	id: String = "01K3UT0000000000000000UT01",
	name: String = "Side Hustle",
	type: TransactionType = .income
) -> Sync.Response.UserCategoryItem {
	Sync.Response.UserCategoryItem(
		id: id, userId: "01K3US0000000000000000US01", name: name, type: type,
		icon: "briefcase", color: "#24389C", createdAt: nil, updatedAt: nil, deletedAt: nil
	)
}

func anyPullSuccessResponse(
	userCategories: [Sync.Response.UserCategoryItem] = [anyUserCategoryItem()]
) -> GeneralResponse<Sync.Response.Pull> {
	GeneralResponse(
		success: true,
		statusCode: 200,
		message: "Sync data fetched.",
		data: Sync.Response.Pull(userCategories: userCategories, serverTime: nil)
	)
}
