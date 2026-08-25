//
//  LoginBrandHeader.swift
//  finance-test-ios
//

import SwiftUI

struct LoginBrandHeader: View {
	/// No-op outside DEBUG builds - the long-press gesture that would call it is only attached
	/// in DEBUG (see `LoginView`/`LoginViewModel.fillTestCredentials()`).
	var onLogoLongPressed: () -> Void = {}

	var body: some View {
		VStack(spacing: 8) {
			Image(.mainIcon)
				.resizable()
				.scaledToFit()
				.frame(width: 49, height: 54)
				.shadow(color: .cardShadow, radius: 4, x: 0, y: 2)
				.padding(.bottom, 8)
				#if DEBUG
				.onLongPressGesture(perform: onLogoLongPressed)
				#endif

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
