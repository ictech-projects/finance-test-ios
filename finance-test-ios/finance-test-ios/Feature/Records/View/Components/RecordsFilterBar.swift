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
					title: "Category", icon: .recordsCategoryIcon, iconSize: CGSize(width: 14.25, height: 15),
					options: availableCategoryNames, selection: $categoryFilter
				)
				RecordsOptionFilterChip(
					title: "Accounts", icon: .recordsAccountsIcon, iconSize: CGSize(width: 14.25, height: 13.5),
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
