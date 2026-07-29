//
//  AuthMockLocalDataSource.swift
//  finance-test-iosTests
//

@testable import finance_test_ios

final class AuthMockLocalDataSource: AuthLocalDataSource {

	enum Invocation: Equatable {
		case saveSession(accessToken: String, refreshToken: String)
		case getAccessToken
		case getRefreshToken
		case clearSession
	}

	private(set) var invocations: [Invocation] = []

	private var accessToken: String?
	private var refreshToken: String?

	init(accessToken: String? = nil, refreshToken: String? = nil) {
		self.accessToken = accessToken
		self.refreshToken = refreshToken
	}

	func saveSession(accessToken: String, refreshToken: String) {
		invocations.append(.saveSession(accessToken: accessToken, refreshToken: refreshToken))
		self.accessToken = accessToken
		self.refreshToken = refreshToken
	}

	func getAccessToken() -> String? {
		invocations.append(.getAccessToken)
		return accessToken
	}

	func getRefreshToken() -> String? {
		invocations.append(.getRefreshToken)
		return refreshToken
	}

	func clearSession() {
		invocations.append(.clearSession)
		accessToken = nil
		refreshToken = nil
	}
}
