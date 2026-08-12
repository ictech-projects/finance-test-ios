//
//  RegisterLoginFooter.swift
//  finance-test-ios
//

import SwiftUI

struct RegisterLoginFooter: View {
	let onLoginTapped: () -> Void

	var body: some View {
		VStack(spacing: 16) {
			Rectangle()
				.fill(Color.neutral50)
				.frame(height: 1)

			HStack(spacing: 4) {
				Text("Already have an account?")
					.font(.baseStyle(size: 14, weight: .regular))
					.foregroundStyle(.neutral90)

				Button(action: onLoginTapped) {
					Text("Log In")
						.font(.baseStyle(size: 14, weight: .bold))
						.foregroundStyle(.brandPrimary)
				}
			}
		}
		.frame(maxWidth: .infinity)
	}
}

#Preview {
	RegisterLoginFooter(onLoginTapped: {})
		.padding()
}
