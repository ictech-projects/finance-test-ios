//
//  CategoryPickerRow.swift
//  finance-test-ios
//

import SwiftUI

struct CategoryPickerRow: View {
	let category: TransactionCategory.Response.CategoryItem
	let isSelected: Bool

	var body: some View {
		HStack(spacing: 12) {
			Circle()
				.fill(swatchColor)
				.frame(width: 32, height: 32)
				.overlay {
					Image(systemName: category.icon ?? "circle.grid.2x2")
						.font(.system(size: 14, weight: .semibold))
						.foregroundStyle(.white)
				}

			Text(category.name ?? "Category")
				.font(.baseStyle(size: 16, weight: .medium))
				.foregroundStyle(.neutral90)

			Spacer()

			if isSelected {
				Image(systemName: "checkmark")
					.foregroundStyle(.brandPrimary)
			}
		}
		.padding(12)
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(isSelected ? Color.neutral20 : .clear)
		)
	}

	private var swatchColor: Color {
		guard let hex = category.color else { return .neutral60 }
		return Color(hex: hex) ?? .neutral60
	}
}

#Preview {
	VStack(spacing: 4) {
		CategoryPickerRow(
			category: TransactionCategory.Response.CategoryItem(
				id: "1", name: "Dining & Drinks", type: .expense, icon: "fork.knife",
				color: "#F97316", createdAt: nil, updatedAt: nil, deletedAt: nil
			),
			isSelected: true
		)
		CategoryPickerRow(
			category: TransactionCategory.Response.CategoryItem(
				id: "2", name: "Transport", type: .expense, icon: "car",
				color: "#6B7280", createdAt: nil, updatedAt: nil, deletedAt: nil
			),
			isSelected: false
		)
	}
	.padding()
}
