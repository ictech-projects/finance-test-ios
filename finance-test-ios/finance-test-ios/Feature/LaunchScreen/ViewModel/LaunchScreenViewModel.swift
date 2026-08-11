//
//  LaunchScreenViewModel.swift
//  finance-test-ios
//

import Combine
import Foundation

@MainActor
final class LaunchScreenViewModel: ObservableObject {

	@Published private(set) var isLaunching = true
	@Published private(set) var isLoggedIn: Bool

	private let sessionStore: any AuthSessionStore
	private var cancellables = Set<AnyCancellable>()

	init(sessionStore: any AuthSessionStore = AuthDefaultSessionStore.shared) {
		self.sessionStore = sessionStore
		self.isLoggedIn = sessionStore.isLoggedIn

		// Keep forwarding the session store's state after the initial decision too, so a later
		// logout (manual Log Out tap, or the 401 plugin) still swaps the app back to
		// LoginView without relaunching.
		sessionStore.isLoggedInPublisher
			.dropFirst()
			.sink { [weak self] isLoggedIn in
				self?.isLoggedIn = isLoggedIn
			}
			.store(in: &cancellables)
	}

	func onAppear() async {
		sessionStore.refreshFromKeychain()
		isLaunching = false
	}
}
