//
//  AuthFlowView.swift
//  finance-test-ios
//

import SwiftUI

struct AuthFlowView: View {
	let onAuthenticated: () -> Void

	@State private var path = NavigationPath()
	@State private var registrationSuccessMessage: String?

	private enum Route: Hashable {
		case register
	}

	var body: some View {
		NavigationStack(path: $path) {
			LoginView(
				successMessage: registrationSuccessMessage,
				onDismissSuccessMessage: { registrationSuccessMessage = nil },
				onSignUpTapped: { path.append(Route.register) },
				onLoginSuccess: onAuthenticated
			)
			.navigationDestination(for: Route.self) { route in
				switch route {
				case .register:
					RegisterView(
						onLoginTapped: { path.removeLast() },
						onRegisterSuccess: {
							registrationSuccessMessage = String(localized: "Account created! Please log in to continue.")
							path.removeLast()
						}
					)
				}
			}
		}
	}
}

#Preview {
	AuthFlowView(onAuthenticated: {})
}
