//
//  AuthMockRepository.swift
//  finance-test-iosTests
//

import Foundation
@testable import finance_test_ios

final class AuthMockRepository: AuthRepository {

	enum Invocation: Equatable {
		case register(Auth.Request.Register)
		case login(Auth.Request.Login)
		case refresh(Auth.Request.Refresh)
		case logout
		case logoutAll
		case getProfile
		case updateProfile(Auth.Request.UpdateProfile)
		case uploadAvatar(imageData: Data, fileName: String, mimeType: String)
		case deleteAvatar
	}

	private(set) var invocations: [Invocation] = []

	private let registerResult: RequestState<GeneralResponse<Auth.Response.Session>>
	private let loginResult: RequestState<GeneralResponse<Auth.Response.Session>>
	private let refreshResult: RequestState<GeneralResponse<Auth.Response.Session>>
	private let logoutResult: RequestState<GeneralResponse<EmptyData>>
	private let logoutAllResult: RequestState<GeneralResponse<EmptyData>>
	private let getProfileResult: RequestState<GeneralResponse<Auth.Response.Profile>>
	private let updateProfileResult: RequestState<GeneralResponse<Auth.Response.Profile>>
	private let uploadAvatarResult: RequestState<GeneralResponse<Auth.Response.Profile>>
	private let deleteAvatarResult: RequestState<GeneralResponse<Auth.Response.Profile>>

	init(
		registerResult: RequestState<GeneralResponse<Auth.Response.Session>> = .idle,
		loginResult: RequestState<GeneralResponse<Auth.Response.Session>> = .idle,
		refreshResult: RequestState<GeneralResponse<Auth.Response.Session>> = .idle,
		logoutResult: RequestState<GeneralResponse<EmptyData>> = .idle,
		logoutAllResult: RequestState<GeneralResponse<EmptyData>> = .idle,
		getProfileResult: RequestState<GeneralResponse<Auth.Response.Profile>> = .idle,
		updateProfileResult: RequestState<GeneralResponse<Auth.Response.Profile>> = .idle,
		uploadAvatarResult: RequestState<GeneralResponse<Auth.Response.Profile>> = .idle,
		deleteAvatarResult: RequestState<GeneralResponse<Auth.Response.Profile>> = .idle
	) {
		self.registerResult = registerResult
		self.loginResult = loginResult
		self.refreshResult = refreshResult
		self.logoutResult = logoutResult
		self.logoutAllResult = logoutAllResult
		self.getProfileResult = getProfileResult
		self.updateProfileResult = updateProfileResult
		self.uploadAvatarResult = uploadAvatarResult
		self.deleteAvatarResult = deleteAvatarResult
	}

	func register(
		request: Auth.Request.Register
	) async throws -> RequestState<GeneralResponse<Auth.Response.Session>> {
		invocations.append(.register(request))
		return registerResult
	}

	func login(
		request: Auth.Request.Login
	) async throws -> RequestState<GeneralResponse<Auth.Response.Session>> {
		invocations.append(.login(request))
		return loginResult
	}

	func refresh(
		request: Auth.Request.Refresh
	) async throws -> RequestState<GeneralResponse<Auth.Response.Session>> {
		invocations.append(.refresh(request))
		return refreshResult
	}

	func logout() async throws -> RequestState<GeneralResponse<EmptyData>> {
		invocations.append(.logout)
		return logoutResult
	}

	func logoutAll() async throws -> RequestState<GeneralResponse<EmptyData>> {
		invocations.append(.logoutAll)
		return logoutAllResult
	}

	func getProfile() async throws -> RequestState<GeneralResponse<Auth.Response.Profile>> {
		invocations.append(.getProfile)
		return getProfileResult
	}

	func updateProfile(
		request: Auth.Request.UpdateProfile
	) async throws -> RequestState<GeneralResponse<Auth.Response.Profile>> {
		invocations.append(.updateProfile(request))
		return updateProfileResult
	}

	func uploadAvatar(
		imageData: Data,
		fileName: String,
		mimeType: String
	) async throws -> RequestState<GeneralResponse<Auth.Response.Profile>> {
		invocations.append(.uploadAvatar(imageData: imageData, fileName: fileName, mimeType: mimeType))
		return uploadAvatarResult
	}

	func deleteAvatar() async throws -> RequestState<GeneralResponse<Auth.Response.Profile>> {
		invocations.append(.deleteAvatar)
		return deleteAvatarResult
	}
}
