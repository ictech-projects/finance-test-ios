//
//  ReportsPeriodToggle.swift
//  finance-test-ios
//

import SwiftUI

struct ReportsPeriodToggle: View {
	let selection: ReportsViewModel.PeriodType
	let onSelect: (ReportsViewModel.PeriodType) -> Void

	@Namespace private var pillNamespace

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
			Capsule().fill(Color.reportsSegmentedTrackBackground)
		)
		.shadow(color: .black.opacity(0.05), radius: 1, y: 1)
		.animation(.spring(response: 0.32, dampingFraction: 0.78), value: selection)
	}

	private func option(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
		Button(action: action) {
			Text(title)
				.font(.baseStyle(size: 14, weight: .semibold))
				.foregroundStyle(isSelected ? .white : .recordsNeutralIconTint)
				.frame(maxWidth: .infinity)
				.padding(.vertical, 8)
				.background {
					if isSelected {
						Capsule()
							.fill(Color.addTransactionFabBackground)
							.matchedGeometryEffect(id: "selectedPill", in: pillNamespace)
					}
				}
		}
		.buttonStyle(ReportsPressableButtonStyle())
	}
}

#Preview {
	@Previewable @State var selection = ReportsViewModel.PeriodType.monthly

	ReportsPeriodToggle(selection: selection) { selection = $0 }
		.padding()
}
