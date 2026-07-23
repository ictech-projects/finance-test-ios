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
						TotalOwedCard(
							totalOwed: viewModel.summary.totalOwed,
							limit: viewModel.summary.owedLimit,
							ratio: viewModel.summary.owedRatio
						)
						.staggeredAppear(index: 4)
						SpendingByCategoryCard(
							categories: viewModel.categories,
							total: viewModel.summary.expense
						)
						.staggeredAppear(index: 5)
						RecentTransactionsSection(transactions: viewModel.transactions)
							.staggeredAppear(index: 6)
					}
					.padding(16)
				}
			}
			.background(Color.brandTertiary.ignoresSafeArea())
			.navigationBarHidden(true)
		}
		.currencySelectionDialog(isPresented: $viewModel.isCurrencyDialogPresented, delegate: viewModel)
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
