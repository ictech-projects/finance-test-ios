//
//  SpendingByCategoryCard.swift
//  finance-test-ios
//

import SwiftUI
import Charts

struct SpendingByCategoryCard: View {
	let categories: [SpendingCategory]
	let total: Double

	@State private var displayedCategories: [SpendingCategory] = []

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			HStack {
				Text("Spending by Category")
					.font(.baseStyle(size: 15, weight: .bold))
					.foregroundStyle(.neutral100)

				Spacer()

				Text("This Month")
					.font(.baseStyle(size: 12, weight: .regular))
					.foregroundStyle(.neutral60)
			}

			ZStack {
				Chart(displayedCategories) { category in
					SectorMark(
						angle: .value("Percent", category.percent),
						innerRadius: .ratio(0.65),
						angularInset: 2
					)
					.foregroundStyle(category.color)
					.cornerRadius(3)
				}
				.chartLegend(.hidden)
				.frame(height: 180)
				.onAppear {
					displayedCategories = categories.map {
						var zeroed = $0
						zeroed.percent = 0
						return zeroed
					}
					withAnimation(.easeOut(duration: 0.8)) {
						displayedCategories = categories
					}
				}

				VStack(spacing: 2) {
					Text("Total")
						.font(.baseStyle(size: 12, weight: .regular))
						.foregroundStyle(.neutral60)

					Text(total.currencyWholeFormatted())
						.font(.baseStyle(size: 20, weight: .bold))
						.foregroundStyle(.neutral100)
				}
			}

			VStack(spacing: 10) {
				ForEach(categoryRows, id: \.0.id) { pair in
					HStack {
						legendItem(pair.0)
						Spacer()
						legendItem(pair.1)
					}
				}
			}
		}
		.frame(maxWidth: .infinity)
		.cardStyle()
	}

	private var categoryRows: [(SpendingCategory, SpendingCategory?)] {
		var rows: [(SpendingCategory, SpendingCategory?)] = []
		var iterator = categories.makeIterator()
		while let first = iterator.next() {
			rows.append((first, iterator.next()))
		}
		return rows
	}

	@ViewBuilder
	private func legendItem(_ category: SpendingCategory?) -> some View {
		if let category {
			HStack(spacing: 8) {
				Circle()
					.fill(category.color)
					.frame(width: 8, height: 8)

				Text("\(category.name) (\(Int(category.percent * 100))%)")
					.font(.baseStyle(size: 13, weight: .regular))
					.foregroundStyle(.neutral90)
			}
		} else {
			EmptyView()
		}
	}
}

#Preview {
	SpendingByCategoryCard(categories: SpendingCategory.mocks, total: 3_100)
		.padding()
}
