//
//  AuthSessionStore.swift
//  finance-test-ios
//

import Combine
import Foundation

/// Single source of truth for whether the user is logged in. `AuthDefaultRepository` updates it
/// internally on login/register/logout, so ViewModels performing those actions only need to
/// depend on `AuthRepository` — they never touch this directly. `LaunchScreenViewModel` and the
/// 401 `UnauthorizedResponsePlugin` are the exceptions: they only observe/force state, not
/// perform an auth action through the repository, so they depend on this directly.
@MainActor
protocol AuthSessionStore: AnyObject {
	var isLoggedIn: Bool { get }
	var isLoggedInPublisher: AnyPublisher<Bool, Never> { get }

	func refreshFromKeychain()
	func markLoggedIn()
	func forceLogout()
}
