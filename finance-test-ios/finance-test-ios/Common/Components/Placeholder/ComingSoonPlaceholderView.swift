//
//  ComingSoonPlaceholderView.swift
//  finance-test-ios
//

import SwiftUI

struct ComingSoonPlaceholderView: View {
	let title: String
	let iconName: String

	var body: some View {
		VStack(spacing: 12) {
			Image(systemName: iconName)
				.font(.system(size: 40))
				.foregroundStyle(.neutral40)

			Text("\(title) coming soon")
				.font(.baseStyle(size: 14, weight: .medium))
				.foregroundStyle(.neutral60)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.neutral20.ignoresSafeArea())
	}
}

#Preview {
	ComingSoonPlaceholderView(title: "Reports", iconName: "chart.pie.fill")
}
