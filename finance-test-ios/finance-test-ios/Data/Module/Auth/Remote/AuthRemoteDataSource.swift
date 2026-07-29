//
//  AuthRemoteDataSource.swift
//  finance-test-ios
//

import Foundation

protocol AuthRemoteDataSource {
	func register(
		request: Auth.Request.Register
	) async throws -> GeneralResponse<Auth.Response.Session>

	func login(
		request: Auth.Request.Login
	) async throws -> GeneralResponse<Auth.Response.Session>

	func refresh(
		request: Auth.Request.Refresh
	) async throws -> GeneralResponse<Auth.Response.Session>

	func logout() async throws -> GeneralResponse<EmptyData>

	func logoutAll() async throws -> GeneralResponse<EmptyData>

	func getProfile() async throws -> GeneralResponse<Auth.Response.Profile>
}
