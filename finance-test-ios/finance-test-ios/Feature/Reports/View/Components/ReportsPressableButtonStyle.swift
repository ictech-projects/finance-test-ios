//
//  ReportsPressableButtonStyle.swift
//  finance-test-ios
//

import SwiftUI

struct ReportsPressableButtonStyle: ButtonStyle {
	func makeBody(configuration: ButtonStyleConfiguration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? 0.94 : 1)
			.animation(.easeOut(duration: 0.15), value: configuration.isPressed)
	}
}
