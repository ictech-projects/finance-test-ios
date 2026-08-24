//
//  ReportsSpendingBreakdownCard.swift
//  finance-test-ios
//

import SwiftUI
import Charts

struct ReportsSpendingBreakdownCard: View {
	let categories: [ReportsCategoryBreakdown]
	let totalSpent: Double
	let onCategoryTapped: (String) -> Void

	@State private var displayedCategories: [ReportsCategoryBreakdown] = []

	private let legendColumns = [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)]

	var body: some View {
		VStack(alignment: .leading, spacing: 24) {
			Text("Spending by Category")
				.font(.baseStyle(size: 16, weight: .semibold))
				.foregroundStyle(.addTransactionValueText)

			ZStack {
				Chart(displayedCategories) { category in
					SectorMark(
						angle: .value("Percent", category.percent),
						innerRadius: .ratio(0.75),
						angularInset: 2
					)
					.foregroundStyle(category.color)
					.cornerRadius(3)
				}
				.chartLegend(.hidden)
				.frame(width: 192, height: 192)
				.task(id: categories.map(\.id)) {
					displayedCategories = categories.map {
						var zeroed = $0
						zeroed.percent = 0
						return zeroed
					}
					withAnimation(.easeOut(duration: 0.8)) {
						displayedCategories = categories
					}
				}

				VStack(spacing: 0) {
					Text("Total Spent")
						.font(.baseStyle(size: 11, weight: .medium))
						.foregroundStyle(.recordsNeutralIconTint)

					Text(totalSpent.currencyWholeFormatted())
						.font(.baseStyle(size: 22, weight: .medium))
						.foregroundStyle(.addTransactionValueText)
						.monospacedDigit()
						.contentTransition(.numericText())
				}
			}
			.frame(maxWidth: .infinity)

			LazyVGrid(columns: legendColumns, spacing: 8) {
				ForEach(categories) { category in
					Button(action: { onCategoryTapped(category.name) }) {
						HStack(spacing: 8) {
							Circle()
								.fill(category.color)
								.frame(width: 12, height: 12)

							Text(category.name)
								.font(.baseStyle(size: 11, weight: .medium))
								.foregroundStyle(.addTransactionValueText)
						}
					}
					.buttonStyle(ReportsPressableButtonStyle())
					.accessibilityIdentifier("reportsCategoryLegendButton")
				}
			}
		}
		.padding(24)
		.frame(maxWidth: .infinity)
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(Color.recordsCardBackground)
		)
		.overlay {
			RoundedRectangle(cornerRadius: 12)
				.stroke(Color.recordsCardBorder, lineWidth: 1)
		}
	}
}

#Preview {
	ReportsSpendingBreakdownCard(
		categories: ReportsPeriodSummary.monthlyMocks.last!.categories, totalSpent: 3_240, onCategoryTapped: { _ in }
	)
	.padding()
	.background(Color.neutral20)
}
