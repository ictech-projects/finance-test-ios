//
//  AuthDefaultRemoteDataSource.swift
//  finance-test-ios
//

import Moya

struct AuthDefaultRemoteDataSource: AuthRemoteDataSource {

	private let provider: MoyaProvider<AuthTargetType>

	init(provider: MoyaProvider<AuthTargetType> = .defaultProvider()) {
		self.provider = provider
	}

	func register(
		request: Auth.Request.Register
	) async throws -> GeneralResponse<Auth.Response.Session> {
		try await provider.request(
			.register(request),
			model: GeneralResponse<Auth.Response.Session>.self
		)
	}

	func login(
		request: Auth.Request.Login
	) async throws -> GeneralResponse<Auth.Response.Session> {
		try await provider.request(
			.login(request),
			model: GeneralResponse<Auth.Response.Session>.self
		)
	}

	func refresh(
		request: Auth.Request.Refresh
	) async throws -> GeneralResponse<Auth.Response.Session> {
		try await provider.request(
			.refresh(request),
			model: GeneralResponse<Auth.Response.Session>.self
		)
	}

	func logout() async throws -> GeneralResponse<EmptyData> {
		try await provider.request(
			.logout,
			model: GeneralResponse<EmptyData>.self
		)
	}

	func logoutAll() async throws -> GeneralResponse<EmptyData> {
		try await provider.request(
			.logoutAll,
			model: GeneralResponse<EmptyData>.self
		)
	}

	func getProfile() async throws -> GeneralResponse<Auth.Response.Profile> {
		try await provider.request(
			.getProfile,
			model: GeneralResponse<Auth.Response.Profile>.self
		)
	}
}
