//
//  UserAvatarView.swift
//  finance-test-ios
//

import SwiftUI

/// A circular user avatar, falling back to a person-icon placeholder when there's no photo.
///
/// `ImageLoader`/`AsyncImage` never resolves past its loading spinner for a `nil` URL (which is
/// what `URL(string: "")` produces), so an empty/missing `avatarUrl` must never be handed to it
/// directly - this is the one place that rule is enforced for every avatar in the app.
struct UserAvatarView: View {
	let avatarUrl: String?
	let size: CGFloat

	var body: some View {
		Group {
			if let avatarUrl, !avatarUrl.isEmpty {
				ImageLoader(path: avatarUrl, width: size, height: size)
			} else {
				Circle()
					.fill(Color.moreSectionCardBackground)
					.frame(width: size, height: size)
					.overlay(
						Image(systemName: "person.fill")
							.font(.system(size: size * 0.36))
							.foregroundStyle(.neutral60)
					)
			}
		}
		.clipShape(Circle())
	}
}

#Preview {
	VStack(spacing: 16) {
		UserAvatarView(avatarUrl: nil, size: 36)
		UserAvatarView(avatarUrl: "", size: 36)
		UserAvatarView(avatarUrl: nil, size: 112)
	}
}
