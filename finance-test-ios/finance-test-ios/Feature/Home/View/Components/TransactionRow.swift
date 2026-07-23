//
//  TransactionRow.swift
//  finance-test-ios
//

import SwiftUI

struct TransactionRow: View {
	let transaction: TransactionItem

	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: transaction.iconName)
				.font(.baseStyle(size: 14, weight: .medium))
				.foregroundStyle(.neutral70)
				.frame(width: 36, height: 36)
				.background(Circle().fill(.neutral20))

			VStack(alignment: .leading, spacing: 2) {
				Text(transaction.title)
					.font(.baseStyle(size: 14, weight: .medium))
					.foregroundStyle(.neutral100)

				Text(transaction.merchant)
					.font(.baseStyle(size: 12, weight: .regular))
					.foregroundStyle(.neutral60)
			}

			Spacer()

			VStack(alignment: .trailing, spacing: 2) {
				Text(transaction.amount.currencyFormatted(showsSign: transaction.isCredit))
					.font(.baseStyle(size: 14, weight: .bold))
					.foregroundStyle(transaction.isCredit ? .homeSuccess : .homeDanger)

				Text("\(transaction.account) • \(transaction.dateLabel)")
					.font(.baseStyle(size: 11, weight: .regular))
					.foregroundStyle(.neutral60)
			}
		}
	}
}

#Preview {
	VStack(spacing: 16) {
		ForEach(TransactionItem.mocks) { transaction in
			TransactionRow(transaction: transaction)
		}
	}
	.padding()
}
