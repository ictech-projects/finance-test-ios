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
		guard emailErrorMessage != nil else { return }
		withAnimation(.easeOut(duration: 0.2)) {
			emailErrorMessage = nil
		}
	}

	func passwordDidChange() {
		guard passwordErrorMessage != nil else { return }
		withAnimation(.easeOut(duration: 0.2)) {
			passwordErrorMessage = nil
		}
	}

	func login() async {
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

		// TODO: Replace with a call into the Auth data layer (Repository) once it exists.
		try? await Task.sleep(nanoseconds: 400_000_000)

		viewState = .initial
	}

	private static func isValidEmail(_ email: String) -> Bool {
		let pattern = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
		return email.range(of: pattern, options: .regularExpression) != nil
	}
}
