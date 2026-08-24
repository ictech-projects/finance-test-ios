//
//  SyncMockRepository.swift
//  finance-test-ios
//

import Foundation

/// Stands in for `SyncDefaultRepository` until the auth module exists and `/sync/push` can
/// actually be called. Echoes each submitted change back as `applied`, using the change's own
/// `data` as the `record` — a generic stand-in is all this shared layer can offer, since the real
/// per-entity record shape is only known to the caller. Swap the default in consuming
/// repositories to `SyncDefaultRepository()` once a valid access token is available.
struct SyncMockRepository: SyncRepository {

	func push(
		request: Sync.Request.Push
	) async -> RequestState<GeneralResponse<Sync.Response.PushResult>> {
		try? await Task.sleep(nanoseconds: 400_000_000)

		let results = request.changes.map { change in
			Sync.Response.ChangeResult(
				clientChangeId: change.clientChangeId,
				id: change.id,
				entity: change.entity,
				status: "applied",
				record: change.data,
				error: nil
			)
		}

		return .loaded(
			GeneralResponse(
				success: true,
				statusCode: 200,
				message: "Changes applied.",
				data: Sync.Response.PushResult(results: results, serverTime: nil)
			)
		)
	}

	func pull(
		request: Sync.Request.Pull
	) async -> RequestState<GeneralResponse<Sync.Response.Pull>> {
		try? await Task.sleep(nanoseconds: 400_000_000)

		return .loaded(
			GeneralResponse(
				success: true,
				statusCode: 200,
				message: "Sync data fetched.",
				data: Sync.Response.Pull(
					userCategories: [
						Sync.Response.UserCategoryItem(
							id: "01K3UT0000000000000000UT01", userId: "01K3US0000000000000000US01",
							name: "Side Hustle", type: .income, icon: "briefcase", color: "#24389C",
							createdAt: nil, updatedAt: nil, deletedAt: nil
						)
					],
					serverTime: nil
				)
			)
		)
	}
}
