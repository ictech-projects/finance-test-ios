//
//  ReportsView.swift
//  finance-test-ios
//

import SwiftUI

struct ReportsView: View {
	/// Pushed from within this screen's own `NavigationStack` — mirrors `CategoryManagementView`'s
	/// local `Route` pattern, since this app has no shared routing enum or `NavigationManager`.
	private enum Route: Hashable {
		case recordsFilteredByCategory(String)
	}

	@StateObject private var viewModel: ReportsViewModel
	@State private var path = NavigationPath()

	init() {
		_viewModel = StateObject(wrappedValue: ReportsViewModel())
	}

	init(viewModel: ReportsViewModel) {
		_viewModel = StateObject(wrappedValue: viewModel)
	}

	var body: some View {
		NavigationStack(path: $path) {
			VStack(spacing: 0) {
				ReportsHeader(onSettingsTapped: {
					// TODO: Navigate to Settings once that screen exists.
				})

				content
					.animation(.easeInOut(duration: 0.25), value: viewModel.viewState)
			}
			.background(Color.neutral20.ignoresSafeArea())
			.navigationBarHidden(true)
			.navigationDestination(for: Route.self) { route in
				switch route {
				case .recordsFilteredByCategory(let categoryName):
					RecordsView(initialCategoryFilter: categoryName, isPushedDestination: true)
				}
			}
		}
		.task {
			await viewModel.onLoad()
		}
		.sheet(isPresented: $viewModel.isPeriodPickerPresented) {
			ReportsPeriodPickerSheet(viewModel: viewModel)
		}
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.viewState {
		case .initial, .loading:
			ProgressView()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.transition(.opacity)
		case .error:
			ContentUnavailableView {
				Label("Couldn't load reports", systemImage: "exclamationmark.triangle")
			} description: {
				Text("Please try again later.")
			} actions: {
				PrimaryButton(size: .mediumIntrinsic, action: {
					Task { await viewModel.onLoad() }
				}) {
					Text("Try Again")
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.transition(.opacity)
		case .loaded:
			loadedContent
				.transition(.opacity)
		}
	}

	private var loadedContent: some View {
		ScrollView {
			VStack(spacing: 16) {
				ReportsPeriodToggle(selection: viewModel.periodType) {
					viewModel.selectPeriodType($0)
				}
				.staggeredAppear(index: 0)

				VStack(spacing: 24) {
					ReportsPeriodSelector(
						periodLabel: viewModel.summary.periodLabel,
						periodSubtitle: viewModel.summary.periodSubtitle,
						canGoToPreviousPeriod: viewModel.canGoToPreviousPeriod,
						canGoToNextPeriod: viewModel.canGoToNextPeriod,
						onPreviousTapped: { viewModel.goToPreviousPeriod() },
						onNextTapped: { viewModel.goToNextPeriod() },
						onLabelTapped: { viewModel.presentPeriodPicker() }
					)
					.disabled(viewModel.isRefreshing)
					.opacity(viewModel.isRefreshing ? 0.5 : 1)
					.animation(.easeInOut(duration: 0.15), value: viewModel.isRefreshing)

					HStack(spacing: 16) {
						ReportsSummaryCard(
							label: "Net Saved",
							value: "+\(viewModel.summary.netSaved.currencyFormatted())",
							valueColor: .reportsPositiveGreen
						)

						ReportsSummaryCard(
							label: "Savings Rate",
							value: "\(viewModel.summary.savingsRatePercent)%",
							trailingSystemImage: "arrow.up.right"
						)
					}

					ReportsSpendingBreakdownCard(
						categories: viewModel.summary.categories,
						totalSpent: viewModel.summary.totalSpent,
						onCategoryTapped: { categoryName in
							path.append(Route.recordsFilteredByCategory(categoryName))
						}
					)

					ReportsTopExpensesSection(expenses: viewModel.summary.topExpenses)
				}
				.staggeredAppear(index: 1)
			}
			.padding(16)
			.animation(.easeInOut(duration: 0.2), value: viewModel.referenceDate)
		}
		.refreshable {
			await viewModel.onLoad()
		}
	}
}

#Preview {
	ReportsView(viewModel: ReportsViewModel(reportsRepository: ReportsMockRepository()))
}
