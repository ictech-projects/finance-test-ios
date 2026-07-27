//
//  LoginSignUpFooter.swift
//  finance-test-ios
//

import SwiftUI

struct LoginSignUpFooter: View {
	let onSignUpTapped: () -> Void

	var body: some View {
		HStack(spacing: 4) {
			Text("Don't have an account?")
				.font(.baseStyle(size: 14, weight: .regular))
				.foregroundStyle(.neutral90)

			Button(action: onSignUpTapped) {
				Text("Sign Up")
					.font(.baseStyle(size: 16, weight: .medium))
					.foregroundStyle(.brandPrimary)
			}
		}
		.frame(maxWidth: .infinity)
	}
}

#Preview {
	LoginSignUpFooter(onSignUpTapped: {})
		.padding()
}
