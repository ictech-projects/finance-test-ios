//
//  RootTabView.swift
//  finance-test-ios
//

import SwiftUI

struct RootTabView: View {
	var body: some View {
		TabView {
			HomeView()
				.tabItem {
					Image(systemName: "house.fill")
					Text("Home")
				}

			ComingSoonPlaceholderView(title: "Records", iconName: "list.bullet.rectangle.fill")
				.tabItem {
					Image(systemName: "list.bullet.rectangle.fill")
					Text("Records")
				}

			ComingSoonPlaceholderView(title: "Reports", iconName: "chart.pie.fill")
				.tabItem {
					Image(systemName: "chart.pie.fill")
					Text("Reports")
				}

			ComingSoonPlaceholderView(title: "More", iconName: "ellipsis.circle.fill")
				.tabItem {
					Image(systemName: "ellipsis.circle.fill")
					Text("More")
				}
		}
		.tint(Color.brandPrimary)
		.tabBarBaseStyle()
	}
}

private struct ComingSoonPlaceholderView: View {
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
	RootTabView()
}
