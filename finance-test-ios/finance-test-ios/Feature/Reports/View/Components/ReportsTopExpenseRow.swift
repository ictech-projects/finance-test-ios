//
//  ReportsTopExpenseRow.swift
//  finance-test-ios
//

import SwiftUI

struct ReportsTopExpenseRow: View {
	let item: ReportsTopExpenseDisplay

	var body: some View {
		HStack(spacing: 16) {
			Image(systemName: item.icon)
				.font(.baseStyle(size: 16, weight: .semibold))
				.foregroundStyle(item.iconTint)
				.frame(width: 40, height: 40)
				.background(Circle().fill(item.iconBackground))

			VStack(alignment: .leading, spacing: 2) {
				Text(item.description)
					.font(.baseStyle(size: 16, weight: .bold))
					.foregroundStyle(.neutral100)

				Text("\(item.categoryName) • \(item.dateLabel)")
					.font(.baseStyle(size: 13, weight: .regular))
					.foregroundStyle(.neutral70)
			}

			Spacer(minLength: 8)

			Text(item.amountLabel)
				.font(.baseStyle(size: 16, weight: .bold))
				.foregroundStyle(.dangerMain)
		}
		.padding(16)
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(Color.recordsCardBackground)
		)
		.overlay(
			RoundedRectangle(cornerRadius: 12)
				.stroke(Color.recordsCardBorder, lineWidth: 1)
		)
	}
}

#Preview {
	VStack(spacing: 8) {
		ForEach(ReportsTopExpenseDisplay.mocks) { item in
			ReportsTopExpenseRow(item: item)
		}
	}
	.padding()
}
