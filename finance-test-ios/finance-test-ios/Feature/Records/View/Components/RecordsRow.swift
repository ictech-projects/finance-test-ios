//
//  RecordsRow.swift
//  finance-test-ios
//

import SwiftUI

struct RecordsRow: View {
	let item: RecordsRowDisplay

	var body: some View {
		HStack(alignment: .top, spacing: 16) {
			Image(systemName: item.categoryIcon)
				.font(.system(size: 20, weight: .medium))
				.foregroundStyle(item.categoryIconTint)
				.frame(width: 48, height: 48)
				.background(Circle().fill(item.categoryIconBackground))

			VStack(alignment: .leading, spacing: 0) {
				Text(item.categoryName)
					.font(.baseStyle(size: 16, weight: .bold))
					.foregroundStyle(.neutral100)

				Text(item.description)
					.font(.baseStyle(size: 14, weight: .regular))
					.foregroundStyle(.neutral90)

				HStack(spacing: 4) {
					Image(systemName: item.accountIcon)
						.font(.system(size: 11, weight: .medium))
					Text(item.accountName)
						.font(.baseStyle(size: 11, weight: .medium))
				}
				.foregroundStyle(.neutral70)
				.padding(.top, 2)
			}

			Spacer(minLength: 8)

			VStack(alignment: .trailing, spacing: 6) {
				Text(item.amountLabel)
					.font(.baseStyle(size: 16, weight: .bold))
					.foregroundStyle(item.isCredit ? .successMain : .dangerMain)

				Text(item.timeLabel)
					.font(.baseStyle(size: 11, weight: .medium))
					.foregroundStyle(.neutral70)
			}
		}
		.padding(17)
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
	VStack(spacing: 4) {
		ForEach(RecordsRowDisplay.mocks) { item in
			RecordsRow(item: item)
		}
	}
	.padding()
}
