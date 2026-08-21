//
//  SyncDefaultRemoteDataSource.swift
//  finance-test-ios
//

import Moya

struct SyncDefaultRemoteDataSource: SyncRemoteDataSource {

	private let provider: MoyaProvider<SyncTargetType>

	init(provider: MoyaProvider<SyncTargetType> = .defaultProvider()) {
		self.provider = provider
	}

	func push(
		request: Sync.Request.Push
	) async throws -> GeneralResponse<Sync.Response.PushResult> {
		try await provider.request(
			.push(request),
			model: GeneralResponse<Sync.Response.PushResult>.self
		)
	}

	func pull(
		request: Sync.Request.Pull
	) async throws -> GeneralResponse<Sync.Response.Pull> {
		try await provider.request(
			.pull(request),
			model: GeneralResponse<Sync.Response.Pull>.self
		)
	}
}
