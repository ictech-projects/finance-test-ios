//
//  LoginView.swift
//  finance-test-ios
//

import SwiftUI

struct LoginView: View {
	@StateObject private var viewModel = LoginViewModel()
	@FocusState private var focusedField: Field?
	var successMessage: String? = nil
	var onDismissSuccessMessage: () -> Void = {}
	var onSignUpTapped: () -> Void = {}
	var onLoginSuccess: () -> Void = {}

	private enum Field {
		case email
		case password
	}

	var body: some View {
		VStack(spacing: 24) {
			Spacer()

			LoginBrandHeader()
				.staggeredAppear(index: 0)

			VStack(spacing: 16) {
				LoginEmailField(email: $viewModel.email, errorMessage: viewModel.emailErrorMessage)
					.focused($focusedField, equals: .email)
					.onChange(of: viewModel.email) { viewModel.emailDidChange() }

				LoginPasswordField(
					password: $viewModel.password,
					isVisible: $viewModel.isPasswordVisible,
					errorMessage: viewModel.passwordErrorMessage,
					onForgotPasswordTapped: {
						// TODO: Navigate to Forgot Password once that screen exists.
					}
				)
				.focused($focusedField, equals: .password)
				.onChange(of: viewModel.password) { viewModel.passwordDidChange() }

				PrimaryButton(
					size: .large,
					backgroundColor: .brandPrimary,
					isDisabled: viewModel.isSubmitDisabled,
					action: {
						focusedField = nil
						Task { await viewModel.login() }
					}
				) {
					if viewModel.viewState == .loading {
						ProgressView()
							.tint(.white)
					} else {
						Text("Login")
					}
				}
			}
			.disabled(viewModel.isSubmitting)
			.phaseAnimator([0, -8, 8, -4, 0], trigger: viewModel.viewState) { content, phase in
				content.offset(x: viewModel.viewState == .error ? phase : 0)
			} animation: { _ in
				.easeInOut(duration: 0.08)
			}
			.staggeredAppear(index: 1)

			LoginSignUpFooter(onSignUpTapped: onSignUpTapped)
				.disabled(viewModel.isSubmitting)
				.staggeredAppear(index: 2)

			Spacer()
		}
		.padding(.horizontal, 32)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.neutral10.ignoresSafeArea())
		.toolbar(.hidden, for: .navigationBar)
		.sensoryFeedback(.error, trigger: viewModel.viewState) { _, new in
			new == .error
		}
		.onSubmit {
			switch focusedField {
			case .email:
				focusedField = .password
			case .password, nil:
				focusedField = nil
				Task { await viewModel.login() }
			}
		}
		.onChange(of: viewModel.isLoggedIn) { _, isLoggedIn in
			guard isLoggedIn else { return }
			onLoginSuccess()
		}
		.baseAlert(
			isPresented: Binding(
				get: { viewModel.generalErrorMessage != nil },
				set: { isPresented in
					if !isPresented {
						viewModel.dismissGeneralError()
					}
				}
			),
			type: .error,
			title: String(localized: "Login Failed"),
			message: viewModel.generalErrorMessage ?? "",
			confirmLabel: Text("OK"),
			confirmAction: { viewModel.dismissGeneralError() }
		)
		.baseAlert(
			isPresented: Binding(
				get: { successMessage != nil },
				set: { isPresented in
					if !isPresented {
						onDismissSuccessMessage()
					}
				}
			),
			type: .success,
			title: String(localized: "Account Created"),
			message: successMessage ?? "",
			confirmLabel: Text("Log In"),
			confirmAction: { onDismissSuccessMessage() }
		)
	}
}

#Preview {
	LoginView()
}
