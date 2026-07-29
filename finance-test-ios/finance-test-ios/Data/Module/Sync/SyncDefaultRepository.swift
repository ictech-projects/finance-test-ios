//
//  SyncDefaultRepository.swift
//  finance-test-ios
//

import Foundation

struct SyncDefaultRepository: SyncRepository {

	private let remote: any SyncRemoteDataSource

	init(remote: some SyncRemoteDataSource = SyncDefaultRemoteDataSource()) {
		self.remote = remote
	}

	func push(
		request: Sync.Request.Push
	) async throws -> RequestState<GeneralResponse<Sync.Response.PushResult>> {
		await execute { try await remote.push(request: request) }
	}
}
