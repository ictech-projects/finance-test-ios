//
//  RecordsOptionFilterChip.swift
//  finance-test-ios
//

import SwiftUI

/// Generic single-select filter chip for a dynamic list of option names (Category, Account),
/// where `nil` selection means "All".
struct RecordsOptionFilterChip: View {
	let title: String
	let icon: ImageResource
	let iconSize: CGSize
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
				Image(icon)
					.renderingMode(.template)
					.resizable()
					.scaledToFit()
					.frame(width: iconSize.width, height: iconSize.height)
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
	RecordsOptionFilterChip(
		title: "Category", icon: .recordsCategoryIcon, iconSize: CGSize(width: 14.25, height: 15),
		options: ["Dining & Drinks", "Transport"], selection: .constant(nil)
	)
	.padding()
}
