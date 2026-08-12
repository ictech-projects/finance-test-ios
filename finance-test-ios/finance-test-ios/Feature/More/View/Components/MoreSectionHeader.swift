//
//  MoreSectionHeader.swift
//  finance-test-ios
//

import SwiftUI

/// Small uppercase section header, e.g. "APPEARANCE" / "MANAGEMENT".
struct MoreSectionHeader: View {
	let title: String

	var body: some View {
		Text(title)
			.textCase(.uppercase)
			.font(.baseStyle(size: 14, weight: .bold))
			.tracking(0.7)
			.foregroundStyle(.moreHeading)
			.padding(.horizontal, 4)
	}
}

#Preview {
	MoreSectionHeader(title: "Appearance")
}
