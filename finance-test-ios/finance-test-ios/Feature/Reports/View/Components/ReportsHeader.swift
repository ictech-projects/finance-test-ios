//
//  ReportsHeader.swift
//  finance-test-ios
//

import SwiftUI

struct ReportsHeader: View {
	let onSettingsTapped: () -> Void

	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: "person.crop.circle.fill")
				.resizable()
				.scaledToFit()
				.frame(width: 32, height: 32)
				.foregroundStyle(.addTransactionFabBackground)
				.clipShape(Circle())

			Text("Reports")
				.font(.baseStyle(size: 24, weight: .semibold))
				.foregroundStyle(.reportsAccentText)

			Spacer()

			Button(action: onSettingsTapped) {
				Image(systemName: "gearshape.fill")
					.font(.baseStyle(size: 20, weight: .medium))
					.foregroundStyle(.reportsAccentText)
			}
		}
		.padding(.horizontal, 16)
		.frame(height: 64)
		.background(Color.neutral10)
	}
}

#Preview {
	ReportsHeader(onSettingsTapped: {})
}
