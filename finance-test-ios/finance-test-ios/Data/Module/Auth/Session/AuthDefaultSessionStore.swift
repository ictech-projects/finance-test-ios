//
//  AuthDefaultSessionStore.swift
//  finance-test-ios
//

import Combine
import Foundation

@MainActor
final class AuthDefaultSessionStore: AuthSessionStore, ObservableObject {

	static let shared = AuthDefaultSessionStore()

	@Published private(set) var isLoggedIn: Bool

	var isLoggedInPublisher: AnyPublisher<Bool, Never> {
		$isLoggedIn.eraseToAnyPublisher()
	}

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

	/// Clears the local session and flips `isLoggedIn`. Idempotent — safe to call from both
	/// `AuthDefaultRepository.logout()`/`.logoutAll()` and the 401 interceptor without
	/// double-clearing.
	func forceLogout() {
		guard isLoggedIn else { return }
		localDataSource.clearSession()
		isLoggedIn = false
	}
}
