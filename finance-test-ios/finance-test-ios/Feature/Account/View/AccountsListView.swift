//
//  AccountsListView.swift
//  finance-test-ios
//

import SwiftUI

struct AccountsListView: View {
	private enum Route: Hashable {
		case edit(Account.Response.AccountItem)
		case add
	}

	@StateObject private var viewModel = AccountsViewModel()
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		VStack(spacing: 0) {
			TopBarView(title: "Accounts", onBackPressed: { dismiss() })
			content
		}
		.background(Color.splashSurface.ignoresSafeArea())
		.navigationBarHidden(true)
		.navigationDestination(for: Route.self) { route in
			switch route {
			case .edit(let account):
				AccountFormView(account: account, delegate: viewModel)
			case .add:
				AccountFormView(account: nil, delegate: viewModel)
			}
		}
		.task {
			await viewModel.onLoad()
		}
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.viewState {
		case .initial, .loading:
			ProgressView()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
		case .error:
			ContentUnavailableView(
				"Couldn't load accounts",
				systemImage: "building.columns",
				description: Text("Please try again later.")
			)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		case .loaded:
			loadedContent
		}
	}

	private var loadedContent: some View {
		VStack(spacing: 0) {
			ScrollView {
				VStack(alignment: .leading, spacing: 16) {
					Text("Manage your linked accounts and manual wallets used for tracking transactions.")
						.font(.baseStyle(size: 13, weight: .regular))
						.foregroundStyle(.neutral60)

					VStack(spacing: 8) {
						ForEach(viewModel.accounts, id: \.self) { account in
							NavigationLink(value: Route.edit(account)) {
								AccountRow(account: account)
							}
							.buttonStyle(.plain)
						}
					}
				}
				.padding(16)
			}

			NavigationLink(value: Route.add) {
				Label("Add New Account", systemImage: "plus")
					.font(.baseStyle(size: 16, weight: .bold))
					.foregroundStyle(.white)
					.frame(maxWidth: .infinity)
					.frame(height: 56)
					.background(RoundedRectangle(cornerRadius: 12).fill(Color.brandPrimary))
			}
			.buttonStyle(.plain)
			.padding(16)
		}
	}
}

private struct AccountRow: View {
	let account: Account.Response.AccountItem

	private var typeOption: AccountFormViewModel.AccountTypeOption {
		AccountFormViewModel.AccountTypeOption(rawValue: account.type ?? "") ?? .fallback
	}

	private var swatchColor: Color {
		Color(hex: account.color ?? "") ?? Color(hex: typeOption.defaultColorHex) ?? .brandPrimary
	}

	private var balanceValue: Double {
		Double(account.balance ?? account.initialBalance ?? "0") ?? 0
	}

	private var balanceText: String {
		balanceValue.formatted(.currency(code: "USD"))
	}

	var body: some View {
		HStack(spacing: 12) {
			ZStack {
				Circle()
					.fill(swatchColor.opacity(0.15))
					.frame(width: 44, height: 44)

				Image(systemName: typeOption.icon)
					.foregroundStyle(swatchColor)
			}

			VStack(alignment: .leading, spacing: 2) {
				Text(account.name ?? "Untitled Account")
					.font(.baseStyle(size: 15, weight: .semibold))
					.foregroundStyle(.neutral100)

				Text(typeOption.label)
					.font(.baseStyle(size: 13, weight: .regular))
					.foregroundStyle(.neutral60)
			}

			Spacer()

			VStack(alignment: .trailing, spacing: 2) {
				Text(balanceText)
					.font(.baseStyle(size: 15, weight: .semibold))
					.foregroundStyle(balanceValue < 0 ? .dangerMain : .successMain)

				Image(systemName: "pencil")
					.font(.system(size: 12, weight: .semibold))
					.foregroundStyle(.neutral50)
			}
		}
		.padding(14)
		.background(RoundedRectangle(cornerRadius: 12).fill(Color.moreSectionCardBackground))
	}
}

#Preview {
	NavigationStack {
		AccountsListView()
	}
}
