//
//  RegisterPasswordField.swift
//  finance-test-ios
//

import SwiftUI

struct RegisterPasswordField: View {
	@Binding var password: String
	var errorMessage: String? = nil

	var body: some View {
		SecureField("••••••••", text: $password)
			.font(.baseStyle(size: 16, weight: .regular))
			.textContentType(.newPassword)
			.modifier(
				SecureFieldWithTitle(
					title: Text("Password"),
					strokeColor: .neutral50,
					leftIcon: Image(.lockIcon),
					leftIconColor: .neutral70,
					errorDescription: errorMessage.map(Text.init)
				)
			)
	}
}

#Preview {
	@Previewable @State var password = ""

	VStack(spacing: 24) {
		RegisterPasswordField(password: $password)
		RegisterPasswordField(password: $password, errorMessage: "Please enter your password.")
	}
	.padding()
}
