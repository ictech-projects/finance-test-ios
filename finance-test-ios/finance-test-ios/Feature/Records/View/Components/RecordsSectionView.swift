//
//  RecordsSectionView.swift
//  finance-test-ios
//

import SwiftUI

struct RecordsSectionView: View {
	let section: RecordsSection
	var startIndex: Int = 0

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack {
				Text(section.title)
					.font(.baseStyle(size: 16, weight: .bold))
					.foregroundStyle(.neutral90)

				Spacer()

				Text(section.subtitle)
					.font(.baseStyle(size: 11, weight: .medium))
					.foregroundStyle(.neutral70)
			}
			.padding(.horizontal, 8)

			VStack(spacing: 4) {
				ForEach(Array(section.items.enumerated()), id: \.element.id) { offset, item in
					RecordsRow(item: item)
						.staggeredAppear(index: startIndex + offset)
				}
			}
		}
	}
}

#Preview {
	ScrollView {
		VStack(spacing: 24) {
			ForEach(RecordsSection.mocks) { section in
				RecordsSectionView(section: section)
			}
		}
		.padding()
	}
}
