//
//  ProfileViewModel.swift
//  finance-test-ios
//

import Combine
import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
	enum ViewState: Equatable {
		case idle
		case saving
		case uploadingAvatar
	}

	@Published var name: String
	@Published private(set) var user: Auth.Response.User
	@Published private(set) var viewState = ViewState.idle
	@Published var isErrorPresented = false
	@Published private(set) var errorMessage = ""

	private let authRepository: any AuthRepository

	init(user: Auth.Response.User, authRepository: some AuthRepository = AuthDefaultRepository()) {
		self.user = user
		self.name = user.name
		self.authRepository = authRepository
	}

	var isSaveDisabled: Bool {
		let trimmedName = name.trimmingCharacters(in: .whitespaces)
		return viewState != .idle || trimmedName.isEmpty || trimmedName == user.name
	}

	func saveName() async {
		let trimmedName = name.trimmingCharacters(in: .whitespaces)

		guard !trimmedName.isEmpty else {
			errorMessage = String(localized: "Please enter your name.")
			isErrorPresented = true
			return
		}

		viewState = .saving

		do {
			let state = try await authRepository.updateProfile(request: Auth.Request.UpdateProfile(name: trimmedName))
			apply(state, syncName: true)
		} catch {
			handleError(error)
		}
	}

	func uploadAvatar(imageData: Data, fileName: String = "avatar.jpg", mimeType: String = "image/jpeg") async {
		viewState = .uploadingAvatar

		do {
			let state = try await authRepository.uploadAvatar(imageData: imageData, fileName: fileName, mimeType: mimeType)
			apply(state, syncName: false)
		} catch {
			handleError(error)
		}
	}

	func removeAvatar() async {
		viewState = .uploadingAvatar

		do {
			let state = try await authRepository.deleteAvatar()
			apply(state, syncName: false)
		} catch {
			handleError(error)
		}
	}

	/// `syncName` is false for avatar operations so a successful upload/removal never clobbers
	/// a name edit the user has typed but not yet saved.
	private func apply(_ state: RequestState<GeneralResponse<Auth.Response.Profile>>, syncName: Bool) {
		switch state {
		case .loaded(let response):
			guard let updatedUser = response.data?.user else {
				handleError(ErrorResponse(
					success: false,
					statusCode: -1,
					message: String(localized: "Something went wrong. Please try again."),
					errors: nil
				))
				return
			}
			user = updatedUser
			if syncName {
				name = updatedUser.name
			}
			viewState = .idle
		case .error(let error):
			handleError(error)
		default:
			viewState = .idle
		}
	}

	private func handleError(_ error: Error) {
		viewState = .idle
		errorMessage = (error as? ErrorResponse)?.message ?? String(localized: "Something went wrong. Please try again.")
		isErrorPresented = true
	}
}
