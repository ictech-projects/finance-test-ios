//
//  SessionStore.swift
//  finance-test-ios
//

import Combine
import Foundation

/// Single source of truth for whether the user is logged in, backed by the Keychain-stored
/// access token. Read by `LaunchScreenViewModel` to gate the app root between `LoginView` and
/// `RootTabView`, and updated by `LoginViewModel` (on successful login), `MoreViewModel` (on
/// Log Out), and `UnauthorizedResponsePlugin` (on any 401 from an authenticated endpoint).
@MainActor
final class SessionStore: ObservableObject {

	static let shared = SessionStore()

	@Published private(set) var isLoggedIn: Bool

	private let localDataSource: any AuthLocalDataSource

	init(localDataSource: some AuthLocalDataSource = AuthDefaultLocalDataSource()) {
		self.localDataSource = localDataSource
		self.isLoggedIn = localDataSource.getAccessToken() != nil
	}

	func refreshFromKeychain() {
		isLoggedIn = localDataSource.getAccessToken() != nil
	}

	func markLoggedIn() {
		isLoggedIn = true
	}

	/// Clears the local session and flips `isLoggedIn`. Idempotent — safe to call from both the
	/// manual Log Out flow and the 401 interceptor without double-clearing.
	func forceLogout() {
		guard isLoggedIn else { return }
		localDataSource.clearSession()
		isLoggedIn = false
	}
}
