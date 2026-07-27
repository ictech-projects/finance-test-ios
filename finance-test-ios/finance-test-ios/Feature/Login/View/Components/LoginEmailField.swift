//
//  LoginEmailField.swift
//  finance-test-ios
//

import SwiftUI

struct LoginEmailField: View {
	@Binding var email: String
	var errorMessage: String? = nil

	var body: some View {
		// Uses a fullwidth "＠" (U+FF20) instead of "@" — a literal email-shaped placeholder
		// like "name@company.com" triggers iOS's system entity detection, which force-tints
		// the placeholder blue regardless of any foregroundStyle/tint/textContentType override.
		TextField("name＠company.com", text: $email)
			.font(.baseStyle(size: 16, weight: .regular))
			.modifier(
				TextFieldWithTitle(
					title: Text("Email Address"),
					capitalization: .never,
					keyboardType: .emailAddress,
					strokeColor: .neutral50,
					leftIcon: Image(.emailIcon),
					leftIconColor: .neutral70,
					errorDescription: errorMessage.map(Text.init)
				)
			)
	}
}

#Preview {
	@Previewable @State var email = ""

	VStack(spacing: 24) {
		LoginEmailField(email: $email)
		LoginEmailField(email: $email, errorMessage: "Please enter a valid email address.")
	}
	.padding()
}
