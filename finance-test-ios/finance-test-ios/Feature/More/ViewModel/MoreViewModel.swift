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

	init(authRepository: some AuthRepository = AuthDefaultRepository()) {
		self.authRepository = authRepository
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

	/// `AuthDefaultRepository.logout()` guarantees the local session is cleared and the shared
	/// `AuthSessionStore` is flipped regardless of the remote call's outcome — a network
	/// failure here must never leave the user stuck logged in on this device.
	func logOutTapped() async {
		guard !isLoggingOut else { return }
		isLoggingOut = true
		_ = try? await authRepository.logout()
		isLoggingOut = false
	}
}
