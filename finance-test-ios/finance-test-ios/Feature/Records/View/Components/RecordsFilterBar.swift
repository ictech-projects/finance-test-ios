//
//  RecordsFilterBar.swift
//  finance-test-ios
//

import SwiftUI

struct RecordsFilterBar: View {
	@Binding var typeFilter: RecordsTypeFilter
	@Binding var categoryFilter: String?
	@Binding var accountFilter: String?
	let availableCategoryNames: [String]
	let availableAccountNames: [String]

	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 12) {
				RecordsMonthChip(label: "This Month")
				RecordsTypeFilterChip(selection: $typeFilter)
				RecordsOptionFilterChip(
					title: "Category", iconName: "tag.fill",
					options: availableCategoryNames, selection: $categoryFilter
				)
				RecordsOptionFilterChip(
					title: "Accounts", iconName: "rectangle.stack.fill",
					options: availableAccountNames, selection: $accountFilter
				)
			}
		}
	}
}

#Preview {
	RecordsFilterBar(
		typeFilter: .constant(.all),
		categoryFilter: .constant(nil),
		accountFilter: .constant(nil),
		availableCategoryNames: ["Dining & Drinks", "Transport"],
		availableAccountNames: ["Cash", "Main Bank"]
	)
	.padding()
}
