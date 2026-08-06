//
//  SyncRepository.swift
//  finance-test-ios
//

protocol SyncRepository {
	func push(
		request: Sync.Request.Push
	) async throws -> RequestState<GeneralResponse<Sync.Response.PushResult>>
}
