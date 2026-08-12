//
//  RegisterFullNameField.swift
//  finance-test-ios
//

import SwiftUI

struct RegisterFullNameField: View {
	@Binding var fullName: String
	var errorMessage: String? = nil

	var body: some View {
		TextField("Enter your full name", text: $fullName)
			.font(.baseStyle(size: 16, weight: .regular))
			.modifier(
				TextFieldWithTitle(
					title: Text("Full Name"),
					capitalization: .words,
					strokeColor: .neutral50,
					leftIcon: Image(.personIcon),
					leftIconColor: .neutral70,
					errorDescription: errorMessage.map(Text.init)
				)
			)
	}
}

#Preview {
	@Previewable @State var fullName = ""

	VStack(spacing: 24) {
		RegisterFullNameField(fullName: $fullName)
		RegisterFullNameField(fullName: $fullName, errorMessage: "Please enter your full name.")
	}
	.padding()
}
