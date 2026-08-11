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
	private let minimumDisplayDuration: Duration
	private var cancellables = Set<AnyCancellable>()

	init(
		sessionStore: any AuthSessionStore = AuthDefaultSessionStore.shared,
		minimumDisplayDuration: Duration = .milliseconds(500)
	) {
		self.sessionStore = sessionStore
		self.minimumDisplayDuration = minimumDisplayDuration
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
		// The Keychain check above is synchronous and effectively instant — without an actual
		// suspension point here, `isLaunching` can flip back to false before a single frame of
		// the spinner ever gets presented, making the splash imperceptible. This guarantees it's
		// actually visible, without reintroducing an artificial multi-second wait.
		try? await Task.sleep(for: minimumDisplayDuration)
		isLaunching = false
	}
}
