//
//  LoginViewModel.swift
//  finance-test-ios
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
	enum ViewState: Equatable {
		case initial
		case loading
		case error
	}

	@Published var email = ""
	@Published var password = ""
	@Published var isPasswordVisible = false
	@Published var viewState = ViewState.initial
	@Published var emailErrorMessage: String?
	@Published var passwordErrorMessage: String?
	@Published var generalErrorMessage: String?
	@Published private(set) var isLoggedIn = false

	private let authRepository: any AuthRepository

	init(authRepository: some AuthRepository = AuthDefaultRepository()) {
		self.authRepository = authRepository
	}

	var isSubmitDisabled: Bool {
		email.isEmpty || password.isEmpty || viewState == .loading
	}

	var isSubmitting: Bool {
		viewState == .loading
	}

	func togglePasswordVisibility() {
		isPasswordVisible.toggle()
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

	func dismissGeneralError() {
		generalErrorMessage = nil
		if viewState == .error {
			viewState = .initial
		}
	}

	func login() async {
		generalErrorMessage = nil
		var hasError = false

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

		guard !hasError else {
			withAnimation(.easeOut(duration: 0.2)) {
				viewState = .error
			}
			return
		}

		viewState = .loading

		do {
			let state = try await authRepository.login(
				request: Auth.Request.Login(email: email, password: password)
			)

			switch state {
			case .loaded:
				isLoggedIn = true
				viewState = .initial
			case .error(let error):
				handleLoginError(error)
			default:
				break
			}
		} catch {
			handleLoginError(error)
		}
	}

	/// Maps a login failure to either field-specific errors (422 validation, e.g. "email must be
	/// a valid email address") or a general error (401 "Invalid credentials." — deliberately
	/// non-field-specific so the API doesn't reveal whether the email or the password was wrong).
	private func handleLoginError(_ error: Error) {
		emailErrorMessage = nil
		passwordErrorMessage = nil
		generalErrorMessage = nil

		if let errorResponse = error as? ErrorResponse {
			let emailError = errorResponse.errors?.email?.first
			let passwordError = errorResponse.errors?.password?.first

			if emailError != nil || passwordError != nil {
				emailErrorMessage = emailError
				passwordErrorMessage = passwordError
			} else {
				generalErrorMessage = errorResponse.message ?? String(localized: "Invalid email or password.")
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

	#if DEBUG
	/// Long-pressing the logo on the Login screen calls this to autofill a known-good tester
	/// account against wallet.birchlabs.tech - manual-QA convenience only, never compiled into
	/// a Release build.
	func fillTestCredentials() {
		email = "profile.tester.1787546663@example.com"
		password = "TestPass123!"
	}
	#endif
}
