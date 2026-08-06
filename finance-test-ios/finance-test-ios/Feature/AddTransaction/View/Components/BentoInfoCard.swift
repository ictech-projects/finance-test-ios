//
//  BentoInfoCard.swift
//  finance-test-ios
//

import SwiftUI

/// Matches Figma's "Details Section (Bento style cards)" — Account and Date are shown as
/// equal-width tappable tiles (icon + small label + bold value) rather than full-width rows.
struct BentoInfoCard: View {
	let systemImageName: String
	let label: String
	let value: String
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			HStack(spacing: 12) {
				Image(systemName: systemImageName)
					.font(.baseStyle(size: 18, weight: .semibold))
					.foregroundStyle(.brandPrimary)

				VStack(alignment: .leading, spacing: 0) {
					Text(label)
						.font(.baseStyle(size: 11, weight: .medium))
						.foregroundStyle(.addTransactionMutedLabel)

					Text(value)
						.font(.baseStyle(size: 16, weight: .semibold))
						.foregroundStyle(.addTransactionValueText)
						.lineLimit(1)
				}

				Spacer(minLength: 0)
			}
			.padding(17)
			.frame(maxWidth: .infinity)
			.background(
				RoundedRectangle(cornerRadius: 16)
					.fill(Color.recordsCardBackground)
			)
			.overlay {
				RoundedRectangle(cornerRadius: 16)
					.stroke(Color.recordsCardBorder, lineWidth: 1)
			}
		}
		.buttonStyle(.plain)
	}
}

#Preview {
	HStack(spacing: 16) {
		BentoInfoCard(systemImageName: "creditcard", label: "Account", value: "Main Debit", action: {})
		BentoInfoCard(systemImageName: "calendar", label: "Date", value: "Today", action: {})
	}
	.padding()
	.background(Color.neutral20)
}
