//
//  RecordsMonthChip.swift
//  finance-test-ios
//

import SwiftUI

/// Static for now — date-range picking needs a calendar UI that's out of scope for this pass.
struct RecordsMonthChip: View {
	let label: String

	var body: some View {
		HStack(spacing: 8) {
			Image(systemName: "calendar")
			Text(label)
				.font(.baseStyle(size: 14, weight: .bold))
			Image(systemName: "chevron.down")
				.font(.baseStyle(size: 8, weight: .bold))
		}
		.foregroundStyle(.neutral80)
		.padding(.horizontal, 16)
		.padding(.vertical, 9)
		.background(Capsule().fill(Color.recordsChipSelectedBackground))
	}
}

#Preview {
	RecordsMonthChip(label: "This Month")
		.padding()
}
