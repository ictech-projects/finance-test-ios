//
//  AuthMockSessionStore.swift
//  finance-test-iosTests
//

import Combine
@testable import finance_test_ios

@MainActor
final class AuthMockSessionStore: AuthSessionStore {

	enum Invocation: Equatable {
		case refreshFromKeychain
		case markLoggedIn
		case forceLogout
	}

	private(set) var invocations: [Invocation] = []

	@Published private(set) var isLoggedIn: Bool

	var isLoggedInPublisher: AnyPublisher<Bool, Never> {
		$isLoggedIn.eraseToAnyPublisher()
	}

	init(isLoggedIn: Bool = false) {
		self.isLoggedIn = isLoggedIn
	}

	func refreshFromKeychain() {
		invocations.append(.refreshFromKeychain)
	}

	func markLoggedIn() {
		invocations.append(.markLoggedIn)
		isLoggedIn = true
	}

	func forceLogout() {
		invocations.append(.forceLogout)
		isLoggedIn = false
	}
}
