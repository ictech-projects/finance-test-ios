//
//  RecordsOptionFilterChip.swift
//  finance-test-ios
//

import SwiftUI

/// Generic single-select filter chip for a dynamic list of option names (Category, Account),
/// where `nil` selection means "All".
struct RecordsOptionFilterChip: View {
	let title: String
	let iconName: String
	let options: [String]
	@Binding var selection: String?

	var body: some View {
		Menu {
			Button("All") { selection = nil }
			ForEach(options, id: \.self) { option in
				Button(option) { selection = option }
			}
		} label: {
			HStack(spacing: 8) {
				Image(systemName: iconName)
				Text(selection ?? title)
					.lineLimit(1)
			}
			.font(.baseStyle(size: 14, weight: .bold))
			.foregroundStyle(selection == nil ? .neutral90 : .neutral80)
			.padding(.horizontal, 17)
			.padding(.vertical, 9)
			.background(
				Capsule().fill(selection == nil ? Color.clear : Color.recordsChipSelectedBackground)
			)
			.overlay(Capsule().stroke(Color.recordsCardBorder, lineWidth: 1))
		}
	}
}

#Preview {
	RecordsOptionFilterChip(title: "Category", iconName: "tag.fill", options: ["Dining & Drinks", "Transport"], selection: .constant(nil))
		.padding()
}
