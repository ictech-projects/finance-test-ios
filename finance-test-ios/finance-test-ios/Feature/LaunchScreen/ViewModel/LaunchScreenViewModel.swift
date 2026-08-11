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

	private let sessionStore: SessionStore
	private var cancellables = Set<AnyCancellable>()

	init(sessionStore: SessionStore = .shared) {
		self.sessionStore = sessionStore
		self.isLoggedIn = sessionStore.isLoggedIn

		// Keep forwarding SessionStore's state after the initial decision too, so a later
		// logout (manual Log Out tap, or the 401 plugin) still swaps the app back to
		// LoginView without relaunching. No `.receive(on:)` hop needed — SessionStore and
		// this view model are both @MainActor, so the emission is already synchronous here.
		sessionStore.$isLoggedIn
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
