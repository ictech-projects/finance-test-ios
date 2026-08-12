//
//  RegisterViewModel.swift
//  finance-test-ios
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class RegisterViewModel: ObservableObject {
	enum ViewState: Equatable {
		case initial
		case loading
		case error
	}

	@Published var fullName = ""
	@Published var email = ""
	@Published var password = ""
	@Published var confirmPassword = ""
	@Published var isAgreedToTerms = false
	@Published var viewState = ViewState.initial
	@Published var fullNameErrorMessage: String?
	@Published var emailErrorMessage: String?
	@Published var passwordErrorMessage: String?
	@Published var confirmPasswordErrorMessage: String?
	@Published var termsErrorMessage: String?
	@Published var generalErrorMessage: String?
	@Published private(set) var isRegistered = false

	private let authRepository: any AuthRepository

	init(authRepository: some AuthRepository = AuthDefaultRepository()) {
		self.authRepository = authRepository
	}

	var isSubmitDisabled: Bool {
		fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || viewState == .loading
	}

	var isSubmitting: Bool {
		viewState == .loading
	}

	func toggleAgreedToTerms() {
		isAgreedToTerms.toggle()
		guard isAgreedToTerms, termsErrorMessage != nil else { return }
		withAnimation(.easeOut(duration: 0.2)) {
			termsErrorMessage = nil
		}
	}

	func fullNameDidChange() {
		guard fullNameErrorMessage != nil || generalErrorMessage != nil else { return }
		withAnimation(.easeOut(duration: 0.2)) {
			fullNameErrorMessage = nil
			generalErrorMessage = nil
		}
	}

	func emailDidChange() {
		guard emailErrorMessage != nil || generalErrorMessage != nil else { return }
		withAnimation(.easeOut(duration: 0.2)) {
			emailErrorMessage = nil
			generalErrorMessage = nil
		}
	}

	func passwordDidChange() {
		guard passwordErrorMessage != nil || generalErrorMessage != nil else { return }
		withAnimation(.easeOut(duration: 0.2)) {
			passwordErrorMessage = nil
			generalErrorMessage = nil
		}
	}

	func confirmPasswordDidChange() {
		guard confirmPasswordErrorMessage != nil || generalErrorMessage != nil else { return }
		withAnimation(.easeOut(duration: 0.2)) {
			confirmPasswordErrorMessage = nil
			generalErrorMessage = nil
		}
	}

	func dismissGeneralError() {
		generalErrorMessage = nil
		if viewState == .error {
			viewState = .initial
		}
	}

	func register() async {
		generalErrorMessage = nil
		var hasError = false

		if fullName.trimmingCharacters(in: .whitespaces).isEmpty {
			fullNameErrorMessage = String(localized: "Please enter your full name.")
			hasError = true
		} else {
			fullNameErrorMessage = nil
		}

		if email.isEmpty {
			emailErrorMessage = String(localized: "Please enter your email.")
			hasError = true
		} else if !Self.isValidEmail(email) {
			emailErrorMessage = String(localized: "Please enter a valid email address.")
			hasError = true
		} else {
			emailErrorMessage = nil
		}

		if password.isEmpty {
			passwordErrorMessage = String(localized: "Please enter your password.")
			hasError = true
		} else {
			passwordErrorMessage = nil
		}

		if confirmPassword.isEmpty {
			confirmPasswordErrorMessage = String(localized: "Please confirm your password.")
			hasError = true
		} else if confirmPassword != password {
			confirmPasswordErrorMessage = String(localized: "Passwords do not match.")
			hasError = true
		} else {
			confirmPasswordErrorMessage = nil
		}

		if !isAgreedToTerms {
			termsErrorMessage = String(localized: "Please agree to the Terms & Conditions and Privacy Policy to continue.")
			hasError = true
		} else {
			termsErrorMessage = nil
		}

		guard !hasError else {
			withAnimation(.easeOut(duration: 0.2)) {
				viewState = .error
			}
			return
		}

		viewState = .loading

		do {
			let state = try await authRepository.register(
				request: Auth.Request.Register(
					name: fullName,
					email: email,
					password: password,
					passwordConfirmation: confirmPassword
				)
			)

			switch state {
			case .loaded:
				isRegistered = true
				viewState = .initial
			case .error(let error):
				handleRegisterError(error)
			default:
				break
			}
		} catch {
			handleRegisterError(error)
		}
	}

	/// Maps a register failure to field-specific errors (422 validation, e.g. "email has already
	/// been taken") or a general error (any other failure not tied to a specific field).
	private func handleRegisterError(_ error: Error) {
		fullNameErrorMessage = nil
		emailErrorMessage = nil
		passwordErrorMessage = nil
		confirmPasswordErrorMessage = nil
		generalErrorMessage = nil

		if let errorResponse = error as? ErrorResponse {
			let nameError = errorResponse.errors?.name?.first
			let emailError = errorResponse.errors?.email?.first
			let passwordError = errorResponse.errors?.password?.first
			let confirmPasswordError = errorResponse.errors?.passwordConfirmation?.first

			if nameError != nil || emailError != nil || passwordError != nil || confirmPasswordError != nil {
				fullNameErrorMessage = nameError
				emailErrorMessage = emailError
				passwordErrorMessage = passwordError
				confirmPasswordErrorMessage = confirmPasswordError
			} else {
				generalErrorMessage = errorResponse.message ?? String(localized: "Unable to create your account. Please try again.")
			}
		} else {
			generalErrorMessage = String(localized: "Something went wrong. Please try again.")
		}

		withAnimation(.easeOut(duration: 0.2)) {
			viewState = .error
		}
	}

	private static func isValidEmail(_ email: String) -> Bool {
		let pattern = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
		return email.range(of: pattern, options: .regularExpression) != nil
	}
}
