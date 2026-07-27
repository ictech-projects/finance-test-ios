//
//  LoginPasswordField.swift
//  finance-test-ios
//

import SwiftUI

struct LoginPasswordField: View {
	@Binding var password: String
	@Binding var isVisible: Bool
	var errorMessage: String? = nil
	let onForgotPasswordTapped: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			HStack {
				Text("Password")
					.font(.baseStyle(size: 16, weight: .medium))
					.foregroundStyle(.neutral90)

				Spacer()

				Button(action: onForgotPasswordTapped) {
					Text("Forgot Password?")
						.font(.baseStyle(size: 14, weight: .medium))
						.foregroundStyle(.brandPrimary)
				}
			}

			Group {
				if isVisible {
					TextField("••••••••", text: $password)
						.font(.baseStyle(size: 16, weight: .regular))
						.modifier(
							TextFieldWithTitle(
								title: nil,
								strokeColor: .neutral50,
								leftIcon: Image(.lockIcon),
								leftIconColor: .neutral70,
								rightIcon: Image(.eye),
								rightIconColor: .neutral70,
								errorDescription: errorMessage.map(Text.init),
								onRightIconPressed: { isVisible.toggle() }
							)
						)
				} else {
					SecureField("••••••••", text: $password)
						.font(.baseStyle(size: 16, weight: .regular))
						.modifier(
							SecureFieldWithTitle(
								title: nil,
								strokeColor: .neutral50,
								leftIcon: Image(.lockIcon),
								leftIconColor: .neutral70,
								rightIcon: Image(.eyeOff),
								rightIconColor: .neutral70,
								errorDescription: errorMessage.map(Text.init),
								onRightIconPressed: { isVisible.toggle() }
							)
						)
				}
			}
		}
	}
}

#Preview {
	@Previewable @State var password = ""
	@Previewable @State var isVisible = false

	VStack(spacing: 24) {
		LoginPasswordField(password: $password, isVisible: $isVisible, onForgotPasswordTapped: {})
		LoginPasswordField(
			password: $password,
			isVisible: $isVisible,
			errorMessage: "Please enter your password.",
			onForgotPasswordTapped: {}
		)
	}
	.padding()
}
