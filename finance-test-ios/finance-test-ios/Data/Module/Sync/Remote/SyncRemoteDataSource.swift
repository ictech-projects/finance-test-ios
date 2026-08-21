//
//  SyncRemoteDataSource.swift
//  finance-test-ios
//

import Foundation

protocol SyncRemoteDataSource {
	func push(
		request: Sync.Request.Push
	) async throws -> GeneralResponse<Sync.Response.PushResult>

	func pull(
		request: Sync.Request.Pull
	) async throws -> GeneralResponse<Sync.Response.Pull>
}
