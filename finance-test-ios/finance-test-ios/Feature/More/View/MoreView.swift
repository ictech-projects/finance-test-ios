//
//  MoreView.swift
//  finance-test-ios
//

import SwiftUI

struct MoreView: View {
	@StateObject private var viewModel = MoreViewModel()
	@State private var isLogOutConfirmationPresented = false

	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				header
				content
			}
			.background(Color.splashSurface.ignoresSafeArea())
			.navigationBarHidden(true)
			.navigationDestination(for: MoreDestination.self) { destination in
				switch destination {
				case .currency:
					UserCurrenciesListView()
				case .appearance:
					AppearanceSettingView()
				case .accounts, .categories:
					ComingSoonPlaceholderView(title: destination.placeholderTitle, iconName: destination.iconName)
				}
			}
		}
		.task {
			await viewModel.onLoad()
		}
		.baseAlert(
			isPresented: $isLogOutConfirmationPresented,
			type: .warning,
			title: "Log Out",
			message: "Are you sure you want to log out?",
			confirmButtonColor: .dangerMain,
			confirmLabel: Text("Log Out"),
			cancelLabel: Text("Cancel"),
			confirmAction: {
				isLogOutConfirmationPresented = false
				Task { await viewModel.logOutTapped() }
			},
			cancelAction: { isLogOutConfirmationPresented = false }
		)
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

				logOutButton
			}
			.padding(16)
		}
	}

	private var logOutButton: some View {
		PrimaryButton(
			size: .large,
			backgroundColor: .dangerSurface,
			strokeColor: .dangerBorder,
			isDisabled: viewModel.isLoggingOut,
			action: { isLogOutConfirmationPresented = true }
		) {
			if viewModel.isLoggingOut {
				ProgressView()
					.tint(.dangerMain)
			} else {
				Text("Log Out")
					.font(.baseStyle(size: 16, weight: .bold))
					.foregroundStyle(.dangerMain)
			}
		}
	}
}

#Preview {
	MoreView()
}
