//
//  ReportsPeriodSelector.swift
//  finance-test-ios
//

import SwiftUI

/// Matches Figma's "Period Selector" — prev/next chevrons around a centered title + subtitle.
struct ReportsPeriodSelector: View {
	let title: String
	let subtitle: String
	let onPrevious: () -> Void
	let onNext: () -> Void

	var body: some View {
		HStack {
			Button(action: onPrevious) {
				Image(systemName: "chevron.left")
					.font(.baseStyle(size: 14, weight: .bold))
					.foregroundStyle(.neutral80)
					.frame(width: 24, height: 34)
			}

			Spacer()

			VStack(spacing: 2) {
				Text(title)
					.font(.baseStyle(size: 16, weight: .bold))
					.foregroundStyle(.neutral100)

				Text(subtitle)
					.font(.baseStyle(size: 12, weight: .regular))
					.foregroundStyle(.neutral60)
			}

			Spacer()

			Button(action: onNext) {
				Image(systemName: "chevron.right")
					.font(.baseStyle(size: 14, weight: .bold))
					.foregroundStyle(.neutral80)
					.frame(width: 24, height: 34)
			}
		}
	}
}

#Preview {
	ReportsPeriodSelector(
		title: "September 2023", subtitle: "4 weeks remaining",
		onPrevious: {}, onNext: {}
	)
	.padding()
}
