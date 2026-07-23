//
//  RecentTransactionsSection.swift
//  finance-test-ios
//

import SwiftUI

struct RecentTransactionsSection: View {
	let transactions: [TransactionItem]
	var onViewAll: () -> Void = {}

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			HStack {
				Text("Recent Transactions")
					.font(.baseStyle(size: 16, weight: .bold))
					.foregroundStyle(.neutral100)

				Spacer()

				Button(action: onViewAll) {
					Text("View All")
						.font(.baseStyle(size: 13, weight: .medium))
						.foregroundStyle(.brandPrimary)
				}
			}

			VStack(spacing: 16) {
				ForEach(transactions) { transaction in
					TransactionRow(transaction: transaction)
				}
			}
		}
		.frame(maxWidth: .infinity)
	}
}

#Preview {
	RecentTransactionsSection(transactions: TransactionItem.mocks)
		.padding()
}
