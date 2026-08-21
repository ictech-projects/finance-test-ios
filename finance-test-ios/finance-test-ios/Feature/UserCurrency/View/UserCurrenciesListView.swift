//
//  UserCurrenciesListView.swift
//  finance-test-ios
//

import SwiftUI

struct UserCurrenciesListView: View {
	private enum Route: Hashable {
		case edit(UserCurrencyDisplayItem)
		case addCurrency
	}

	@StateObject private var viewModel = UserCurrenciesViewModel()
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		VStack(spacing: 0) {
			TopBarView(title: "User Currencies", onBackPressed: { dismiss() })
			content
		}
		.background(Color.splashSurface.ignoresSafeArea())
		.navigationBarHidden(true)
		.navigationDestination(for: Route.self) { route in
			switch route {
			case .edit(let displayItem):
				EditUserCurrencyView(displayItem: displayItem, anchorCurrencyCode: viewModel.anchorCurrencyCode, delegate: viewModel)
			case .addCurrency:
				CurrencyCatalogPickerView(alreadyAddedCurrencyIds: viewModel.addedCurrencyIds, delegate: viewModel)
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
				"Couldn't load your currencies",
				systemImage: "dollarsign.circle",
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
				VStack(spacing: 8) {
					ForEach(viewModel.rows) { row in
						NavigationLink(value: Route.edit(row)) {
							UserCurrencyRow(displayItem: row)
						}
						.buttonStyle(.plain)
					}
				}
				.padding(16)
			}

			NavigationLink(value: Route.addCurrency) {
				Text("Add Currency")
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

private struct UserCurrencyRow: View {
	let displayItem: UserCurrencyDisplayItem

	var body: some View {
		HStack(spacing: 12) {
			if let currency = displayItem.currency {
				CurrencyAvatarView(currency: currency)
			}

			VStack(alignment: .leading, spacing: 2) {
				Text(displayItem.currency?.name ?? "Unknown Currency")
					.font(.baseStyle(size: 15, weight: .semibold))
					.foregroundStyle(.neutral100)

				Text(displayItem.currency?.code ?? "—")
					.font(.baseStyle(size: 13, weight: .regular))
					.foregroundStyle(.neutral60)
			}

			Spacer()

			Image(systemName: "chevron.right")
				.font(.system(size: 12, weight: .semibold))
				.foregroundStyle(.neutral50)
		}
		.padding(14)
		.background(RoundedRectangle(cornerRadius: 12).fill(Color.moreSectionCardBackground))
	}
}

#Preview {
	NavigationStack {
		UserCurrenciesListView()
	}
}
