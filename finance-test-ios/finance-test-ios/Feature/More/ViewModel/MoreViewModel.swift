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
}
