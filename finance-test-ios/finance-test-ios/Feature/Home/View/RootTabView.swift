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

			RecordsView()
				.tabItem {
					Image(systemName: "list.bullet.rectangle.fill")
					Text("Records")
				}

			ComingSoonPlaceholderView(title: "Reports", iconName: "chart.pie.fill")
				.tabItem {
					Image(systemName: "chart.pie.fill")
					Text("Reports")
				}

			MoreView()
				.tabItem {
					Image(systemName: "ellipsis.circle.fill")
					Text("More")
				}
		}
		.tint(Color.brandPrimary)
		.tabBarBaseStyle()
	}
}

#Preview {
	RootTabView()
}
