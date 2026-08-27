//
//  CategoryGridItem.swift
//  finance-test-ios
//

import SwiftUI

/// Matches Figma's "Section - Category Grid" — categories are chosen directly from an inline
/// icon grid, not a bottom sheet.
struct CategoryGridItem: View {
	let category: Sync.Response.UserCategoryItem
	let isSelected: Bool
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			VStack(spacing: 4) {
				Image(systemName: CategoryIconResolver.symbol(for: category.icon))
					.font(.baseStyle(size: 18, weight: .semibold))
					.foregroundStyle(isSelected ? .white : .recordsNeutralIconTint)
					.frame(width: 56, height: 56)
					.background(
						RoundedRectangle(cornerRadius: 16)
							.fill(isSelected ? Color.brandPrimary : .recordsCardBackground)
					)
					.overlay {
						RoundedRectangle(cornerRadius: 16)
							.stroke(isSelected ? Color.brandPrimary : .recordsCardBorder, lineWidth: 1)
					}

				Text(category.name ?? "Category")
					.font(.baseStyle(size: 11, weight: .medium))
					.foregroundStyle(.recordsNeutralIconTint)
					.lineLimit(1)
					.minimumScaleFactor(0.8)
			}
			.frame(maxWidth: .infinity)
		}
		.buttonStyle(.plain)
	}
}

#Preview {
	HStack(spacing: 16) {
		CategoryGridItem(
			category: Sync.Response.UserCategoryItem(
				id: "1", userId: nil, name: "Dining", type: .expense, icon: "fork.knife",
				color: "#F97316", createdAt: nil, updatedAt: nil, deletedAt: nil
			),
			isSelected: true,
			action: {}
		)
		CategoryGridItem(
			category: Sync.Response.UserCategoryItem(
				id: "2", userId: nil, name: "Transport", type: .expense, icon: "car",
				color: "#6B7280", createdAt: nil, updatedAt: nil, deletedAt: nil
			),
			isSelected: false,
			action: {}
		)
	}
	.padding()
	.background(Color.neutral20)
}
