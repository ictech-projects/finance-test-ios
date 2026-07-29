//
//  RecordsTypeFilterChip.swift
//  finance-test-ios
//

import SwiftUI

struct RecordsTypeFilterChip: View {
	@Binding var selection: RecordsTypeFilter

	var body: some View {
		Menu {
			ForEach(RecordsTypeFilter.allCases) { option in
				Button(option.rawValue) { selection = option }
			}
		} label: {
			HStack(spacing: 8) {
				Image(.recordsTypeIcon)
					.renderingMode(.template)
					.resizable()
					.scaledToFit()
					.frame(width: 13.5, height: 9)
				Text(selection == .all ? "Type" : selection.rawValue)
					.lineLimit(1)
			}
			.font(.baseStyle(size: 14, weight: .bold))
			.foregroundStyle(selection == .all ? .neutral90 : .neutral80)
			.padding(.horizontal, 17)
			.padding(.vertical, 9)
			.background(
				Capsule().fill(selection == .all ? Color.clear : Color.recordsChipSelectedBackground)
			)
			.overlay(Capsule().stroke(Color.recordsCardBorder, lineWidth: 1))
		}
	}
}

#Preview {
	RecordsTypeFilterChip(selection: .constant(.all))
		.padding()
}
