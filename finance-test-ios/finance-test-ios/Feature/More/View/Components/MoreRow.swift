//
//  MoreRow.swift
//  finance-test-ios
//

import SwiftUI

/// Leading icon + label + trailing disclosure chevron, used inside a `MoreView` section card.
struct MoreRow: View {
	let iconName: String
	let title: String

	var body: some View {
		HStack(spacing: 16) {
			Image(systemName: iconName)
				.foregroundStyle(.neutral90)
				.frame(width: 20)

			Text(title)
				.font(.baseStyle(size: 16, weight: .regular))
				.foregroundStyle(.neutral100)

			Spacer()

			Image(systemName: "chevron.right")
				.font(.system(size: 12, weight: .semibold))
				.foregroundStyle(.neutral50)
		}
		.padding(16)
		.contentShape(Rectangle())
	}
}

#Preview {
	MoreRow(iconName: "building.columns.fill", title: "Accounts")
}
