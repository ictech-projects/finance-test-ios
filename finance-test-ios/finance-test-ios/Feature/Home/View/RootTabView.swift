//
//  RootTabView.swift
//  finance-test-ios
//

import SwiftUI

struct RootTabView: View {
	private enum Tab {
		case home
		case records
		case reports
		case more
	}

	@State private var selectedTab = Tab.home
	@ObservedObject private var intentRouter = AppIntentRouter.shared

	var body: some View {
		TabView(selection: $selectedTab) {
			HomeView()
				.tabItem {
					Image(systemName: "house.fill")
					Text("Home")
				}
				.tag(Tab.home)

			RecordsView()
				.tabItem {
					Image(systemName: "list.bullet.rectangle.fill")
					Text("Records")
				}
				.tag(Tab.records)

			ReportsView()
				.tabItem {
					Image(systemName: "chart.pie.fill")
					Text("Reports")
				}
				.tag(Tab.reports)

			MoreView()
				.tabItem {
					Image(systemName: "ellipsis.circle.fill")
					Text("More")
				}
				.tag(Tab.more)
		}
		.tint(Color.brandPrimary)
		.tabBarBaseStyle()
		// Selecting the tab is all this does; `RecordsView` presents the sheet and clears the
		// request, because a `TabView` page isn't built until its tab is selected - so switching
		// here has to happen first. `task(id:)` rather than `onChange` so a request that arrived
		// before this view existed (a control tap that cold-launched the app) is still handled.
		.task(id: intentRouter.pendingRequest) {
			guard intentRouter.pendingRequest == .addExpense else { return }
			selectedTab = .records
		}
	}
}

#Preview {
	RootTabView()
}
