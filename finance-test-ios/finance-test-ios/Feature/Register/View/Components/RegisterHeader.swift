//
//  RegisterHeader.swift
//  finance-test-ios
//

import SwiftUI

struct RegisterHeader: View {
	var body: some View {
		VStack(spacing: 8) {
			Text("Create Account")
				.font(.baseStyle(size: 28, weight: .bold))
				.foregroundStyle(.neutral100)

			Text("Start your journey to fiscal precision.")
				.font(.baseStyle(size: 16, weight: .regular))
				.foregroundStyle(.neutral90)
		}
		.multilineTextAlignment(.center)
		.frame(maxWidth: .infinity)
		.accessibilityElement(children: .combine)
	}
}

#Preview {
	RegisterHeader()
		.padding()
}
