//
//  RegisterConfirmPasswordField.swift
//  finance-test-ios
//

import SwiftUI

struct RegisterConfirmPasswordField: View {
	@Binding var confirmPassword: String
	var errorMessage: String? = nil

	var body: some View {
		SecureField("••••••••", text: $confirmPassword)
			.font(.baseStyle(size: 16, weight: .regular))
			.textContentType(.newPassword)
			.modifier(
				SecureFieldWithTitle(
					title: Text("Confirm Password"),
					strokeColor: .neutral50,
					leftIcon: Image(.retryPassIcon),
					leftIconColor: .neutral70,
					errorDescription: errorMessage.map(Text.init)
				)
			)
	}
}

#Preview {
	@Previewable @State var confirmPassword = ""

	VStack(spacing: 24) {
		RegisterConfirmPasswordField(confirmPassword: $confirmPassword)
		RegisterConfirmPasswordField(
			confirmPassword: $confirmPassword,
			errorMessage: "Passwords do not match."
		)
	}
	.padding()
}
