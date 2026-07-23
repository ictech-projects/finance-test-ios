//
//  View+StaggeredAppear.swift
//  finance-test-ios
//

import SwiftUI

struct StaggeredAppearModifier: ViewModifier {
	let index: Int

	@State private var appeared = false

	func body(content: Content) -> some View {
		content
			.opacity(appeared ? 1 : 0)
			.offset(y: appeared ? 0 : 12)
			.onAppear {
				withAnimation(.easeOut(duration: 0.35).delay(Double(index) * 0.06)) {
					appeared = true
				}
			}
	}
}

extension View {
	func staggeredAppear(index: Int) -> some View {
		modifier(StaggeredAppearModifier(index: index))
	}
}
