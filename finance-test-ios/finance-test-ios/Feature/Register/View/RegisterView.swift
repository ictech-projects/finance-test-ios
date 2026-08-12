//
//  RegisterView.swift
//  finance-test-ios
//

import SwiftUI

struct RegisterView: View {
	@StateObject private var viewModel = RegisterViewModel()
	@FocusState private var focusedField: Field?
	var onLoginTapped: () -> Void = {}
	var onRegisterSuccess: () -> Void = {}

	private enum Field {
		case fullName
		case email
		case password
		case confirmPassword
	}

	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				RegisterHeader()
					.staggeredAppear(index: 0)

				VStack(spacing: 16) {
					RegisterFullNameField(fullName: $viewModel.fullName, errorMessage: viewModel.fullNameErrorMessage)
						.focused($focusedField, equals: .fullName)
						.onChange(of: viewModel.fullName) { viewModel.fullNameDidChange() }

					RegisterEmailField(email: $viewModel.email, errorMessage: viewModel.emailErrorMessage)
						.focused($focusedField, equals: .email)
						.onChange(of: viewModel.email) { viewModel.emailDidChange() }

					RegisterPasswordField(
						password: $viewModel.password,
						errorMessage: viewModel.passwordErrorMessage
					)
					.focused($focusedField, equals: .password)
					.onChange(of: viewModel.password) { viewModel.passwordDidChange() }

					RegisterConfirmPasswordField(
						confirmPassword: $viewModel.confirmPassword,
						errorMessage: viewModel.confirmPasswordErrorMessage
					)
					.focused($focusedField, equals: .confirmPassword)
					.onChange(of: viewModel.confirmPassword) { viewModel.confirmPasswordDidChange() }

					RegisterTermsAgreement(
						isAgreed: $viewModel.isAgreedToTerms,
						errorMessage: viewModel.termsErrorMessage,
						onToggle: { viewModel.toggleAgreedToTerms() },
						onTermsTapped: {
							// TODO: Navigate to Terms & Conditions once that screen exists.
						},
						onPrivacyPolicyTapped: {
							// TODO: Navigate to Privacy Policy once that screen exists.
						}
					)

					PrimaryButton(
						size: .large,
						backgroundColor: .brandPrimary,
						isDisabled: viewModel.isSubmitDisabled,
						action: {
							focusedField = nil
							Task { await viewModel.register() }
						}
					) {
						if viewModel.viewState == .loading {
							ProgressView()
								.tint(.white)
						} else {
							HStack(spacing: 8) {
								Text("Sign Up")
								Image(systemName: "arrow.right")
							}
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

				RegisterLoginFooter(onLoginTapped: onLoginTapped)
					.disabled(viewModel.isSubmitting)
					.staggeredAppear(index: 2)
			}
			.padding(.horizontal, 32)
			.padding(.vertical, 24)
		}
		.scrollDismissesKeyboard(.interactively)
		.background(Color.neutral10.ignoresSafeArea())
		.toolbar(.hidden, for: .navigationBar)
		.sensoryFeedback(.error, trigger: viewModel.viewState) { _, new in
			new == .error
		}
		.onSubmit {
			switch focusedField {
			case .fullName:
				focusedField = .email
			case .email:
				focusedField = .password
			case .password:
				focusedField = .confirmPassword
			case .confirmPassword, nil:
				focusedField = nil
				Task { await viewModel.register() }
			}
		}
		.onChange(of: viewModel.isRegistered) { _, isRegistered in
			guard isRegistered else { return }
			onRegisterSuccess()
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
			title: String(localized: "Registration Failed"),
			message: viewModel.generalErrorMessage ?? "",
			confirmLabel: Text("OK"),
			confirmAction: { viewModel.dismissGeneralError() }
		)
	}
}

#Preview {
	RegisterView()
}
