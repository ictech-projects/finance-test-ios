//
//  ReportsView.swift
//  finance-test-ios
//

import SwiftUI

struct ReportsView: View {
	@StateObject private var viewModel = ReportsViewModel()

	var body: some View {
		VStack(spacing: 0) {
			header
			content
		}
		.background(Color.neutral20.ignoresSafeArea())
		.task {
			await viewModel.onLoad()
		}
	}

	private var header: some View {
		Text("Reports")
			.font(.baseStyle(size: 24, weight: .bold))
			.foregroundStyle(.brandPrimary)
			.frame(maxWidth: .infinity)
			.padding(.vertical, 16)
			.background(Color.neutral10)
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.viewState {
		case .initial, .loading:
			ProgressView()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
		case .error:
			ContentUnavailableView(
				"Couldn't load reports",
				systemImage: "exclamationmark.triangle",
				description: Text("Please try again later.")
			)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		case .loaded:
			loadedContent
		}
	}

	private var loadedContent: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 24) {
				ReportsPeriodToggle(selection: viewModel.periodMode, onSelect: viewModel.selectPeriodMode)

				ReportsPeriodSelector(
					title: viewModel.periodTitle,
					subtitle: viewModel.periodSubtitle,
					onPrevious: viewModel.goToPreviousPeriod,
					onNext: viewModel.goToNextPeriod
				)

				HStack(spacing: 16) {
					ReportsSummaryCard(label: "Net Saved", value: viewModel.netSavedLabel, valueColor: viewModel.netSavedColor)
					ReportsSummaryCard(
						label: "Savings Rate", value: viewModel.savingsRateLabel,
						valueColor: viewModel.savingsRateColor, trendSystemImage: viewModel.savingsRateTrendIcon
					)
				}

				SpendingByCategoryCard(
					categories: viewModel.spendingCategories,
					total: viewModel.summary.totalExpense,
					totalLabel: "Total Spent",
					periodLabel: nil
				)

				topExpensesSection
			}
			.padding(16)
			.animation(.easeInOut(duration: 0.25), value: viewModel.periodDate)
		}
	}

	@ViewBuilder
	private var topExpensesSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Top Expenses")
				.font(.baseStyle(size: 18, weight: .bold))
				.foregroundStyle(.neutral100)

			if viewModel.topExpenses.isEmpty {
				ContentUnavailableView(
					"No Expenses",
					systemImage: "tray",
					description: Text("Expenses for this period will appear here.")
				)
				.frame(maxWidth: .infinity)
				.padding(.top, 24)
			} else {
				ForEach(viewModel.topExpenses) { item in
					ReportsTopExpenseRow(item: item)
				}
			}
		}
	}
}

#Preview {
	ReportsView()
}
