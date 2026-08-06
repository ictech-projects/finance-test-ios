//
//  ReportsSummaryCard.swift
//  finance-test-ios
//

import SwiftUI

/// Matches Figma's "Bento Summary Cards" — Net Saved and Savings Rate shown as equal-width
/// static tiles (label + bold colored value, optional trailing trend arrow).
struct ReportsSummaryCard: View {
	let label: String
	let value: String
	let valueColor: Color
	var trendSystemImage: String?

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(label)
				.font(.baseStyle(size: 12, weight: .medium))
				.foregroundStyle(.neutral60)

			HStack(spacing: 6) {
				Text(value)
					.font(.baseStyle(size: 20, weight: .bold))
					.foregroundStyle(valueColor)

				if let trendSystemImage {
					Image(systemName: trendSystemImage)
						.font(.baseStyle(size: 13, weight: .semibold))
						.foregroundStyle(valueColor)
				}
			}
		}
		.padding(17)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(
			RoundedRectangle(cornerRadius: 16)
				.fill(Color.recordsCardBackground)
		)
		.overlay {
			RoundedRectangle(cornerRadius: 16)
				.stroke(Color.recordsCardBorder, lineWidth: 1)
		}
	}
}

#Preview {
	HStack(spacing: 16) {
		ReportsSummaryCard(label: "Net Saved", value: "+$1,450.20", valueColor: .successMain)
		ReportsSummaryCard(label: "Savings Rate", value: "24%", valueColor: .successMain, trendSystemImage: "arrow.up.right")
	}
	.padding()
	.background(Color.neutral20)
}
