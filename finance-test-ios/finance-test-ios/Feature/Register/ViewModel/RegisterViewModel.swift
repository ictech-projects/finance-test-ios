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

		// TODO: Replace with a call into the Auth data layer (Repository) once wired.
		// When wired, a non-field failure (e.g. duplicate email) should set `generalErrorMessage`
		// and `viewState = .error`, mirroring LoginViewModel.handleLoginError — the alert plumbing
		// in RegisterView is already wired to `generalErrorMessage` and ready to surface it.
		try? await Task.sleep(nanoseconds: 400_000_000)

		isRegistered = true
		viewState = .initial
	}

	private static func isValidEmail(_ email: String) -> Bool {
		let pattern = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
		return email.range(of: pattern, options: .regularExpression) != nil
	}
}
