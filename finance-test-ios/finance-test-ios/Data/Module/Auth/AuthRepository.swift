//
//  AuthRepository.swift
//  finance-test-ios
//

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
}
