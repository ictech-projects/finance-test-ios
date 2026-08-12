//
//  HomeView.swift
//  finance-test-ios
//

import SwiftUI

struct HomeView: View {
	@StateObject private var viewModel = HomeViewModel()

	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				header
				content
			}
			.background(Color.brandTertiary.ignoresSafeArea())
			.navigationBarHidden(true)
		}
		.task {
			await viewModel.onLoad()
		}
		.currencySelectionDialog(isPresented: $viewModel.isCurrencyDialogPresented, delegate: viewModel)
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.viewState {
		case .initial, .loading:
			ProgressView()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
		case .error:
			ContentUnavailableView(
				"Couldn't load your dashboard",
				systemImage: "chart.line.downtrend.xyaxis",
				description: Text("Please try again later.")
			)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		case .loaded:
			loadedContent
		}
	}

	private var loadedContent: some View {
		ScrollView {
			VStack(spacing: 16) {
				BalanceCard(amount: viewModel.summary.balanceThisMonth)
					.staggeredAppear(index: 0)
				NetWorthCard(amount: viewModel.summary.netWorth)
					.staggeredAppear(index: 1)
				IncomeExpenseRow(kind: .income, amount: viewModel.summary.income)
					.staggeredAppear(index: 2)
				IncomeExpenseRow(kind: .expense, amount: viewModel.summary.expense)
					.staggeredAppear(index: 3)
				SpendingByCategoryCard(
					categories: viewModel.categories,
					total: viewModel.summary.expense
				)
				.staggeredAppear(index: 4)
				RecentTransactionsSection(transactions: viewModel.transactions)
					.staggeredAppear(index: 5)
			}
			.padding(16)
		}
	}

	private var header: some View {
		HStack(spacing: 12) {
			Image(systemName: "person.crop.circle.fill")
				.resizable()
				.scaledToFit()
				.frame(width: 36, height: 36)
				.foregroundStyle(.neutral40)
				.clipShape(Circle())

			Text("Financial Architect")
				.font(.baseStyle(size: 18, weight: .bold))
				.foregroundStyle(.brandPrimary)

			Spacer()

			Button {
				viewModel.presentCurrencySelection()
			} label: {
				Image(systemName: "gearshape.fill")
					.font(.baseStyle(size: 18, weight: .medium))
					.foregroundStyle(.brandPrimary)
			}
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 12)
		.background(Color.neutral10)
	}
}

#Preview {
	HomeView()
}
