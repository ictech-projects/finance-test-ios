//
//  AuthDefaultRepository.swift
//  finance-test-ios
//

import Foundation

struct AuthDefaultRepository: AuthRepository {

	private let remote: any AuthRemoteDataSource
	private let local: any AuthLocalDataSource

	init(
		remoteDataSource: some AuthRemoteDataSource = AuthDefaultRemoteDataSource(),
		localDataSource: some AuthLocalDataSource = AuthDefaultLocalDataSource()
	) {
		self.remote = remoteDataSource
		self.local = localDataSource
	}

	func register(
		request: Auth.Request.Register
	) async throws -> RequestState<GeneralResponse<Auth.Response.Session>> {
		do {
			let result = try await remote.register(request: request)
			if let session = result.data {
				local.saveSession(accessToken: session.token, refreshToken: session.refreshToken)
			}
			return .loaded(result)
		} catch let error as ErrorResponse {
			return .error(error)
		} catch {
			return .error(error)
		}
	}

	func login(
		request: Auth.Request.Login
	) async throws -> RequestState<GeneralResponse<Auth.Response.Session>> {
		do {
			let result = try await remote.login(request: request)
			if let session = result.data {
				local.saveSession(accessToken: session.token, refreshToken: session.refreshToken)
			}
			return .loaded(result)
		} catch let error as ErrorResponse {
			return .error(error)
		} catch {
			return .error(error)
		}
	}

	func refresh(
		request: Auth.Request.Refresh
	) async throws -> RequestState<GeneralResponse<Auth.Response.Session>> {
		do {
			let result = try await remote.refresh(request: request)
			if let session = result.data {
				local.saveSession(accessToken: session.token, refreshToken: session.refreshToken)
			}
			return .loaded(result)
		} catch let error as ErrorResponse {
			return .error(error)
		} catch {
			return .error(error)
		}
	}

	func logout() async throws -> RequestState<GeneralResponse<EmptyData>> {
		do {
			let result = try await remote.logout()
			local.clearSession()
			return .loaded(result)
		} catch let error as ErrorResponse {
			return .error(error)
		} catch {
			return .error(error)
		}
	}

	func logoutAll() async throws -> RequestState<GeneralResponse<EmptyData>> {
		do {
			let result = try await remote.logoutAll()
			local.clearSession()
			return .loaded(result)
		} catch let error as ErrorResponse {
			return .error(error)
		} catch {
			return .error(error)
		}
	}

	func getProfile() async throws -> RequestState<GeneralResponse<Auth.Response.Profile>> {
		do {
			let result = try await remote.getProfile()
			return .loaded(result)
		} catch let error as ErrorResponse {
			return .error(error)
		} catch {
			return .error(error)
		}
	}
}
