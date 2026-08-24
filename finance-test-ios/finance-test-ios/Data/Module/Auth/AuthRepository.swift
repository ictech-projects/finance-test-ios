//
//  AuthRepository.swift
//  finance-test-ios
//

import Foundation

protocol AuthRepository {
	func register(
		request: Auth.Request.Register
	) async throws -> RequestState<GeneralResponse<Auth.Response.Session>>

	func login(
		request: Auth.Request.Login
	) async throws -> RequestState<GeneralResponse<Auth.Response.Session>>

	func refresh(
		request: Auth.Request.Refresh
	) async throws -> RequestState<GeneralResponse<Auth.Response.Session>>

	func logout() async throws -> RequestState<GeneralResponse<EmptyData>>

	func logoutAll() async throws -> RequestState<GeneralResponse<EmptyData>>

	func getProfile() async throws -> RequestState<GeneralResponse<Auth.Response.Profile>>

	func updateProfile(
		request: Auth.Request.UpdateProfile
	) async throws -> RequestState<GeneralResponse<Auth.Response.Profile>>

	func uploadAvatar(
		imageData: Data,
		fileName: String,
		mimeType: String
	) async throws -> RequestState<GeneralResponse<Auth.Response.Profile>>

	func deleteAvatar() async throws -> RequestState<GeneralResponse<Auth.Response.Profile>>
}
