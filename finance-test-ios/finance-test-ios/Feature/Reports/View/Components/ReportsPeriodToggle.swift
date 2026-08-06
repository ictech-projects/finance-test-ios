//
//  ReportsPeriodToggle.swift
//  finance-test-ios
//

import SwiftUI

/// Matches Figma's "View Segmented Control" — a 2-segment pill (Monthly/Yearly), same filled
/// sub-pill selection style as `AddTransactionTypeToggle`.
struct ReportsPeriodToggle: View {
	let selection: ReportsPeriodMode
	let onSelect: (ReportsPeriodMode) -> Void

	var body: some View {
		HStack(spacing: 0) {
			option(title: "Monthly", isSelected: selection == .monthly) {
				onSelect(.monthly)
			}
			option(title: "Yearly", isSelected: selection == .yearly) {
				onSelect(.yearly)
			}
		}
		.padding(4)
		.background(
			Capsule().fill(Color.neutral30)
		)
	}

	private func option(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
		Button(action: action) {
			Text(title)
				.font(.baseStyle(size: 14, weight: .semibold))
				.foregroundStyle(isSelected ? .addTransactionToggleSelectedText : .recordsNeutralIconTint)
				.frame(maxWidth: .infinity)
				.padding(.vertical, 8)
				.background(
					Capsule().fill(isSelected ? Color.recordsChipSelectedBackground : .clear)
				)
		}
	}
}

#Preview {
	struct PreviewHost: View {
		@State private var selection = ReportsPeriodMode.monthly

		var body: some View {
			ReportsPeriodToggle(selection: selection) { selection = $0 }
				.padding()
		}
	}

	return PreviewHost()
}
