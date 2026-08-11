//
//  MoreViewModel.swift
//  finance-test-ios
//

import Combine
import Foundation

@MainActor
final class MoreViewModel: ObservableObject {
	enum ViewState: Equatable {
		case initial
		case loading
		case loaded
		case error
	}

	@Published private(set) var viewState = ViewState.initial
	@Published private(set) var profile: Auth.Response.User?
	@Published private(set) var isLoggingOut = false

	private let authRepository: any AuthRepository
	private let sessionStore: SessionStore

	init(authRepository: some AuthRepository = AuthDefaultRepository(), sessionStore: SessionStore = .shared) {
		self.authRepository = authRepository
		self.sessionStore = sessionStore
	}

	func onLoad() async {
		viewState = .loading

		do {
			let state = try await authRepository.getProfile()

			switch state {
			case .loaded(let response):
				profile = response.data?.user
				viewState = .loaded
			case .error:
				viewState = .error
			default:
				break
			}
		} catch {
			viewState = .error
		}
	}

	/// Best-effort remote revoke; the actual "user is logged out" state transition is
	/// guaranteed by `sessionStore.forceLogout()` regardless of the repository's outcome — a
	/// network failure here must never leave the user stuck logged in on this device.
	func logOutTapped() async {
		guard !isLoggingOut else { return }
		isLoggingOut = true
		_ = try? await authRepository.logout()
		sessionStore.forceLogout()
		isLoggingOut = false
	}
}
