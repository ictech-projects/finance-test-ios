//
//  AccountPickerRow.swift
//  finance-test-ios
//

import SwiftUI

struct AccountPickerRow: View {
	let account: Account.Response.AccountItem
	let isSelected: Bool

	var body: some View {
		HStack(spacing: 12) {
			Circle()
				.fill(swatchColor)
				.frame(width: 32, height: 32)
				.overlay {
					Image(.recordsAccountsIcon)
						.renderingMode(.template)
						.resizable()
						.scaledToFit()
						.frame(width: 16, height: 16)
						.foregroundStyle(.white)
				}

			Text(account.name ?? "Account")
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
		guard let hex = account.color else { return .neutral60 }
		return Color(hex: hex) ?? .neutral60
	}
}

#Preview {
	VStack(spacing: 4) {
		AccountPickerRow(
			account: Account.Response.AccountItem(
				id: "1", userId: nil, userCurrencyId: nil, name: "Cash", notes: nil,
				type: "cash", color: "#22C55E", initialBalance: nil, balance: "320",
				isDefault: true, createdAt: nil, updatedAt: nil, deletedAt: nil
			),
			isSelected: true
		)
		AccountPickerRow(
			account: Account.Response.AccountItem(
				id: "2", userId: nil, userCurrencyId: nil, name: "Main Bank", notes: nil,
				type: "bank_account", color: "#24389C", initialBalance: nil, balance: "12480",
				isDefault: false, createdAt: nil, updatedAt: nil, deletedAt: nil
			),
			isSelected: false
		)
	}
	.padding()
}
