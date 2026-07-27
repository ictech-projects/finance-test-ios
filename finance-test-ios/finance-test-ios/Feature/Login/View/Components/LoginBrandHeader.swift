//
//  LoginBrandHeader.swift
//  finance-test-ios
//

import SwiftUI

struct LoginBrandHeader: View {
	var body: some View {
		VStack(spacing: 8) {
			Image(.mainIcon)
				.resizable()
				.scaledToFit()
				.frame(width: 49, height: 54)
				.shadow(color: .cardShadow, radius: 4, x: 0, y: 2)
				.padding(.bottom, 8)

			Text("Welcome Back")
				.font(.baseStyle(size: 28, weight: .bold))
				.foregroundStyle(.neutral100)

			Text("Architecting your financial future.")
				.font(.baseStyle(size: 14, weight: .regular))
				.foregroundStyle(.neutral90)
		}
		.frame(maxWidth: .infinity)
		.accessibilityElement(children: .combine)
	}
}

#Preview {
	LoginBrandHeader()
		.padding()
}
