//
//  AuthDefaultRemoteDataSource.swift
//  finance-test-ios
//

import Foundation
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

	func updateProfile(
		request: Auth.Request.UpdateProfile
	) async throws -> GeneralResponse<Auth.Response.Profile> {
		try await provider.request(
			.updateProfile(request),
			model: GeneralResponse<Auth.Response.Profile>.self
		)
	}

	func uploadAvatar(
		imageData: Data,
		fileName: String,
		mimeType: String
	) async throws -> GeneralResponse<Auth.Response.Profile> {
		try await provider.request(
			.uploadAvatar(imageData: imageData, fileName: fileName, mimeType: mimeType),
			model: GeneralResponse<Auth.Response.Profile>.self
		)
	}

	func deleteAvatar() async throws -> GeneralResponse<Auth.Response.Profile> {
		try await provider.request(
			.deleteAvatar,
			model: GeneralResponse<Auth.Response.Profile>.self
		)
	}
}
