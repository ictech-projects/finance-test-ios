//
//  AuthMockRemoteDataSource.swift
//  finance-test-iosTests
//

import Foundation
@testable import finance_test_ios

final class AuthMockRemoteDataSource: AuthRemoteDataSource {

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

	private let registerResult: Result<GeneralResponse<Auth.Response.Session>, Error>
	private let loginResult: Result<GeneralResponse<Auth.Response.Session>, Error>
	private let refreshResult: Result<GeneralResponse<Auth.Response.Session>, Error>
	private let logoutResult: Result<GeneralResponse<EmptyData>, Error>
	private let logoutAllResult: Result<GeneralResponse<EmptyData>, Error>
	private let getProfileResult: Result<GeneralResponse<Auth.Response.Profile>, Error>
	private let updateProfileResult: Result<GeneralResponse<Auth.Response.Profile>, Error>
	private let uploadAvatarResult: Result<GeneralResponse<Auth.Response.Profile>, Error>
	private let deleteAvatarResult: Result<GeneralResponse<Auth.Response.Profile>, Error>

	init(
		registerResult: Result<GeneralResponse<Auth.Response.Session>, Error> = .success(anySessionSuccessResponse()),
		loginResult: Result<GeneralResponse<Auth.Response.Session>, Error> = .success(anySessionSuccessResponse()),
		refreshResult: Result<GeneralResponse<Auth.Response.Session>, Error> = .success(anySessionSuccessResponse()),
		logoutResult: Result<GeneralResponse<EmptyData>, Error> = .success(anyEmptySuccessResponse()),
		logoutAllResult: Result<GeneralResponse<EmptyData>, Error> = .success(anyEmptySuccessResponse()),
		getProfileResult: Result<GeneralResponse<Auth.Response.Profile>, Error> = .success(anyProfileSuccessResponse()),
		updateProfileResult: Result<GeneralResponse<Auth.Response.Profile>, Error> = .success(anyProfileSuccessResponse()),
		uploadAvatarResult: Result<GeneralResponse<Auth.Response.Profile>, Error> = .success(anyProfileSuccessResponse()),
		deleteAvatarResult: Result<GeneralResponse<Auth.Response.Profile>, Error> = .success(anyProfileSuccessResponse())
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
	) async throws -> GeneralResponse<Auth.Response.Session> {
		invocations.append(.register(request))
		return try registerResult.get()
	}

	func login(
		request: Auth.Request.Login
	) async throws -> GeneralResponse<Auth.Response.Session> {
		invocations.append(.login(request))
		return try loginResult.get()
	}

	func refresh(
		request: Auth.Request.Refresh
	) async throws -> GeneralResponse<Auth.Response.Session> {
		invocations.append(.refresh(request))
		return try refreshResult.get()
	}

	func logout() async throws -> GeneralResponse<EmptyData> {
		invocations.append(.logout)
		return try logoutResult.get()
	}

	func logoutAll() async throws -> GeneralResponse<EmptyData> {
		invocations.append(.logoutAll)
		return try logoutAllResult.get()
	}

	func getProfile() async throws -> GeneralResponse<Auth.Response.Profile> {
		invocations.append(.getProfile)
		return try getProfileResult.get()
	}

	func updateProfile(
		request: Auth.Request.UpdateProfile
	) async throws -> GeneralResponse<Auth.Response.Profile> {
		invocations.append(.updateProfile(request))
		return try updateProfileResult.get()
	}

	func uploadAvatar(
		imageData: Data,
		fileName: String,
		mimeType: String
	) async throws -> GeneralResponse<Auth.Response.Profile> {
		invocations.append(.uploadAvatar(imageData: imageData, fileName: fileName, mimeType: mimeType))
		return try uploadAvatarResult.get()
	}

	func deleteAvatar() async throws -> GeneralResponse<Auth.Response.Profile> {
		invocations.append(.deleteAvatar)
		return try deleteAvatarResult.get()
	}
}

func anyUser(
	id: String = "1",
	name: String = "Jane Doe",
	email: String = "jane.doe@example.com"
) -> Auth.Response.User {
	Auth.Response.User(
		id: id, name: name, email: email, role: "member",
		avatarPath: nil, avatarUrl: nil, emailVerifiedAt: nil, createdAt: nil, updatedAt: nil
	)
}

func anySession(user: Auth.Response.User = anyUser()) -> Auth.Response.Session {
	Auth.Response.Session(
		user: user,
		token: "any-access-token",
		refreshToken: "any-refresh-token",
		refreshExpiresAt: "2026-12-31T00:00:00Z"
	)
}

func anyRegisterRequest() -> Auth.Request.Register {
	Auth.Request.Register(
		name: "Jane Doe",
		email: "jane.doe@example.com",
		password: "password123",
		passwordConfirmation: "password123"
	)
}

func anyLoginRequest() -> Auth.Request.Login {
	Auth.Request.Login(email: "jane.doe@example.com", password: "password123")
}

func anyRefreshRequest() -> Auth.Request.Refresh {
	Auth.Request.Refresh(refreshToken: "any-refresh-token")
}

func anySessionSuccessResponse(session: Auth.Response.Session = anySession()) -> GeneralResponse<Auth.Response.Session> {
	GeneralResponse(success: true, statusCode: 200, message: "Login successful.", data: session)
}

func anyEmptySuccessResponse() -> GeneralResponse<EmptyData> {
	GeneralResponse(success: true, statusCode: 200, message: "Logged out.", data: EmptyData())
}

func anyProfileSuccessResponse(user: Auth.Response.User = anyUser()) -> GeneralResponse<Auth.Response.Profile> {
	GeneralResponse(success: true, statusCode: 200, message: "Profile fetched.", data: Auth.Response.Profile(user: user))
}

func anyErrorField(
	email: [String]? = nil,
	password: [String]? = nil,
	name: [String]? = nil,
	passwordConfirmation: [String]? = nil
) -> ErrorField {
	ErrorField(
		email: email, password: password,
		name: name, passwordConfirmation: passwordConfirmation,
		title: nil, firstName: nil, lastName: nil, preferredFirstName: nil, personalEmail: nil,
		dateOfBirth: nil, gender: nil, personalPhone: nil, personalPhoneCountryCode: nil,
		residentialAddress: nil, isAboriginalOrTorresStraitIslander: nil, emergencyContactName: nil,
		emergencyContactRelationship: nil, emergencyContactPhone: nil, emergencyContactEmail: nil,
		taxFileNumber: nil, bankAccountName: nil, bankAccountNumber: nil, bankBSB: nil, superFund: nil,
		superMemberNumber: nil, drivingLicenseFirstName: nil, drivingLicenseSurname: nil,
		drivingLicenseState: nil, drivingLicenseNumber: nil, drivingLicenseExpiryDate: nil,
		whiteCardNotApplicable: nil, whiteCardFullName: nil, whiteCardCardNumber: nil,
		whiteCardRTONumber: nil, whiteCardDateOfIssue: nil, whiteCardState: nil,
		currentPassword: nil, newName: nil
	)
}
