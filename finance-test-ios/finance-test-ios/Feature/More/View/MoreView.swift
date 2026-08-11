//
//  MoreView.swift
//  finance-test-ios
//

import SwiftUI

struct MoreView: View {
	@StateObject private var viewModel = MoreViewModel()

	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				header
				content
			}
			.background(Color.splashSurface.ignoresSafeArea())
			.navigationBarHidden(true)
			.navigationDestination(for: MoreDestination.self) { destination in
				ComingSoonPlaceholderView(title: destination.placeholderTitle, iconName: destination.iconName)
			}
		}
		.task {
			await viewModel.onLoad()
		}
	}

	private var header: some View {
		Text("More")
			.font(.baseStyle(size: 24, weight: .bold))
			.foregroundStyle(.moreHeading)
			.frame(maxWidth: .infinity)
			.padding(.vertical, 16)
			.background(Color.splashSurface)
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.viewState {
		case .initial, .loading:
			ProgressView()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
		case .error:
			ContentUnavailableView(
				"Couldn't load profile",
				systemImage: "person.crop.circle.badge.exclamationmark",
				description: Text("Please try again later.")
			)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		case .loaded:
			loadedContent
		}
	}

	private var loadedContent: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 24) {
				MoreProfileCard(
					name: viewModel.profile?.name ?? "",
					email: viewModel.profile?.email ?? "",
					onEditProfileTapped: { /* TODO: Navigate to Edit Profile once that screen exists. */ }
				)

				VStack(alignment: .leading, spacing: 8) {
					MoreSectionHeader(title: "Appearance")

					NavigationLink(value: MoreDestination.appearance) {
						MoreRow(iconName: MoreDestination.appearance.iconName, title: MoreDestination.appearance.rowLabel)
					}
					.buttonStyle(.plain)
					.background(RoundedRectangle(cornerRadius: 12).fill(.moreSectionCardBackground))
				}

				VStack(alignment: .leading, spacing: 8) {
					MoreSectionHeader(title: "Management")

					VStack(spacing: 0) {
						ForEach(Array(MoreDestination.managementCases.enumerated()), id: \.element) { index, destination in
							if index > 0 {
								Rectangle()
									.fill(.moreHairline.opacity(0.2))
									.frame(height: 1)
							}

							NavigationLink(value: destination) {
								MoreRow(iconName: destination.iconName, title: destination.rowLabel)
							}
							.buttonStyle(.plain)
						}
					}
					.background(RoundedRectangle(cornerRadius: 12).fill(.moreSectionCardBackground))
				}
			}
			.padding(16)
		}
	}
}

#Preview {
	MoreView()
}
