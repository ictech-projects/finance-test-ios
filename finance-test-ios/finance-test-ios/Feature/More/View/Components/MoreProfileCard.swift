//
//  MoreProfileCard.swift
//  finance-test-ios
//

import SwiftUI

struct MoreProfileCard: View {
	let name: String
	let email: String
	let onEditProfileTapped: () -> Void

	var body: some View {
		HStack(spacing: 12) {
			VStack(alignment: .leading, spacing: 2) {
				Text(name)
					.font(.baseStyle(size: 16, weight: .bold))
					.foregroundStyle(.neutral100)

				Text(email)
					.font(.baseStyle(size: 14, weight: .regular))
					.foregroundStyle(.moreProfileEmailText)
			}

			Spacer()

			Button(action: onEditProfileTapped) {
				Text("Edit Profile")
					.font(.baseStyle(size: 13, weight: .bold))
					.foregroundStyle(.moreEditProfileText)
					.padding(.horizontal, 14)
					.padding(.vertical, 8)
					.background(Capsule().fill(.moreEditProfileBackground))
			}
		}
		.padding(17)
		.background(RoundedRectangle(cornerRadius: 12).fill(.moreProfileCardBackground))
		.overlay(RoundedRectangle(cornerRadius: 12).stroke(.moreHairline.opacity(0.3), lineWidth: 1))
	}
}

#Preview {
	MoreProfileCard(name: "Alex Thompson", email: "alex.t@financialarchitect.com", onEditProfileTapped: {})
		.padding()
}
