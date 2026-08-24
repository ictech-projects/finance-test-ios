//
//  ReportsPeriodSelector.swift
//  finance-test-ios
//

import SwiftUI

struct ReportsPeriodSelector: View {
	let periodLabel: String
	let periodSubtitle: String
	let canGoToPreviousPeriod: Bool
	let canGoToNextPeriod: Bool
	let onPreviousTapped: () -> Void
	let onNextTapped: () -> Void
	let onLabelTapped: () -> Void

	var body: some View {
		HStack {
			chevronButton(systemName: "chevron.left", isEnabled: canGoToPreviousPeriod, action: onPreviousTapped)

			Spacer(minLength: 0)

			Button(action: onLabelTapped) {
				VStack(spacing: 0) {
					Text(periodLabel)
						.font(.baseStyle(size: 16, weight: .semibold))
						.foregroundStyle(.addTransactionValueText)

					Text(periodSubtitle)
						.font(.baseStyle(size: 11, weight: .medium))
						.foregroundStyle(.recordsNeutralIconTint)
				}
			}
			.buttonStyle(.plain)
			.accessibilityElement(children: .combine)
			.accessibilityHint("Opens a picker to jump to a different period.")

			Spacer(minLength: 0)

			chevronButton(systemName: "chevron.right", isEnabled: canGoToNextPeriod, action: onNextTapped)
		}
	}

	private func chevronButton(systemName: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
		Button(action: action) {
			Image(systemName: systemName)
				.font(.baseStyle(size: 14, weight: .semibold))
				.foregroundStyle(isEnabled ? .addTransactionValueText : .neutral40)
				.padding(8)
		}
		.disabled(!isEnabled)
	}
}

#Preview {
	ReportsPeriodSelector(
		periodLabel: "September 2026",
		periodSubtitle: "4 weeks remaining",
		canGoToPreviousPeriod: true,
		canGoToNextPeriod: false,
		onPreviousTapped: {},
		onNextTapped: {},
		onLabelTapped: {}
	)
	.padding()
}
