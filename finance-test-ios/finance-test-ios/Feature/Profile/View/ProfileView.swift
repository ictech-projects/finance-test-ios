//
//  ProfileView.swift
//  finance-test-ios
//

import SwiftUI

struct ProfileView: View {
	@StateObject private var viewModel: ProfileViewModel
	@Environment(\.dismiss) private var dismiss

	private let onProfileUpdated: (Auth.Response.User) -> Void

	init(user: Auth.Response.User, onProfileUpdated: @escaping (Auth.Response.User) -> Void) {
		_viewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
		self.onProfileUpdated = onProfileUpdated
	}

	var body: some View {
		VStack(spacing: 0) {
			TopBarView(title: "Profile", onBackPressed: { dismiss() })

			ScrollView {
				VStack(spacing: 24) {
					profileHeader
					profileInformationCard
				}
				.padding(16)
			}
		}
		.background(Color.splashSurface.ignoresSafeArea())
		.navigationBarHidden(true)
		.animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.user)
		.animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.viewState)
		.onChange(of: viewModel.user) { _, user in onProfileUpdated(user) }
		.baseAlert(
			isPresented: $viewModel.isErrorPresented,
			type: .error,
			title: "Something Went Wrong",
			message: viewModel.errorMessage,
			confirmLabel: Text("OK"),
			confirmAction: {}
		)
	}

	private var profileHeader: some View {
		VStack(spacing: 12) {
			ProfileAvatarView(
				avatarUrl: viewModel.user.avatarUrl,
				hasAvatar: viewModel.user.avatarPath != nil,
				isUploading: viewModel.viewState == .uploadingAvatar,
				onImagePicked: { data in Task { await viewModel.uploadAvatar(imageData: data) } },
				onRemoveTapped: { Task { await viewModel.removeAvatar() } }
			)

			VStack(spacing: 8) {
				Text(viewModel.user.name)
					.font(.baseStyle(size: 20, weight: .bold))
					.foregroundStyle(.neutral100)

				Text(viewModel.user.email)
					.font(.baseStyle(size: 14, weight: .regular))
					.foregroundStyle(.moreProfileEmailText)

				premiumPlanBadge
			}
		}
		.padding(.top, 8)
	}

	/// Static per the Figma design - the wallet API has no plan/subscription concept (only a
	/// generic `role`), so this badge isn't backed by any real data.
	private var premiumPlanBadge: some View {
		HStack(spacing: 6) {
			Image(.verifiedBadgeIcon)
				.renderingMode(.template)
				.resizable()
				.frame(width: 15, height: 14)

			Text("PREMIUM PLAN")
				.font(.baseStyle(size: 12, weight: .bold))
				.tracking(0.2)
		}
		.foregroundStyle(.moreEditProfileText)
		.padding(.horizontal, 14)
		.padding(.vertical, 6)
		.background(Capsule().fill(.moreEditProfileBackground))
	}

	private var profileInformationCard: some View {
		VStack(alignment: .leading, spacing: 20) {
			Text("PROFILE INFORMATION")
				.font(.baseStyle(size: 12, weight: .bold))
				.tracking(0.6)
				.foregroundStyle(.neutral60)

			VStack(alignment: .leading, spacing: 16) {
				TextField("Full Name", text: $viewModel.name)
					.withTitle(Text("Full Name"), capitalization: .words)

				TextField("Email Address", text: .constant(viewModel.user.email))
					.withTitle(Text("Email Address"))
					.disabled(true)
					.opacity(0.6)
			}

			PrimaryButton(
				size: .large,
				backgroundColor: .brandPrimary,
				isDisabled: viewModel.isSaveDisabled,
				action: { Task { await viewModel.saveName() } }
			) {
				if viewModel.viewState == .saving {
					ProgressView()
						.tint(.white)
						.transition(.scale.combined(with: .opacity))
				} else {
					Label {
						Text("Save Changes")
					} icon: {
						Image(.saveIcon)
							.renderingMode(.template)
							.resizable()
							.frame(width: 18, height: 18)
					}
					.transition(.scale.combined(with: .opacity))
				}
			}
		}
		.padding(20)
		.background(RoundedRectangle(cornerRadius: 16).fill(Color.moreSectionCardBackground))
	}
}

#Preview {
	NavigationStack {
		ProfileView(user: .mock, onProfileUpdated: { _ in })
	}
}
