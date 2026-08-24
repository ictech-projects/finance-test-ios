//
//  ReportsSummaryCard.swift
//  finance-test-ios
//

import SwiftUI

struct ReportsSummaryCard: View {
	let label: String
	let value: String
	let valueColor: Color
	let trailingSystemImage: String?

	init(label: String, value: String, valueColor: Color = .addTransactionValueText, trailingSystemImage: String? = nil) {
		self.label = label
		self.value = value
		self.valueColor = valueColor
		self.trailingSystemImage = trailingSystemImage
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(label)
				.font(.baseStyle(size: 11, weight: .medium))
				.foregroundStyle(.recordsNeutralIconTint)

			HStack(alignment: .lastTextBaseline, spacing: 4) {
				Text(value)
					.font(.baseStyle(size: 24, weight: .medium))
					.foregroundStyle(valueColor)

				if let trailingSystemImage {
					Image(systemName: trailingSystemImage)
						.font(.baseStyle(size: 13, weight: .semibold))
						.foregroundStyle(.reportsPositiveGreen)
				}
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(17)
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(Color.recordsCardBackground)
		)
		.overlay {
			RoundedRectangle(cornerRadius: 12)
				.stroke(Color.recordsCardBorder, lineWidth: 1)
		}
	}
}

#Preview {
	HStack(spacing: 16) {
		ReportsSummaryCard(label: "Net Saved", value: "+$1,450.20", valueColor: .reportsPositiveGreen)
		ReportsSummaryCard(label: "Savings Rate", value: "24%", trailingSystemImage: "arrow.up.right")
	}
	.padding()
	.background(Color.neutral20)
}
