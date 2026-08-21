//
//  CurrencyCatalogPickerView.swift
//  finance-test-ios
//

import SwiftUI

struct CurrencyCatalogPickerView<Delegate: UserCurrencyMutationDelegate>: View {
	@StateObject private var viewModel: CurrencyCatalogPickerViewModel
	@Environment(\.dismiss) private var dismiss

	init(alreadyAddedCurrencyIds: Set<String>, delegate: Delegate) {
		_viewModel = StateObject(
			wrappedValue: CurrencyCatalogPickerViewModel(alreadyAddedCurrencyIds: alreadyAddedCurrencyIds, delegate: delegate)
		)
	}

	var body: some View {
		VStack(spacing: 0) {
			TopBarView(title: "Select Currency", onBackPressed: { dismiss() })
			searchField
			content
		}
		.background(Color.splashSurface.ignoresSafeArea())
		.navigationBarHidden(true)
		.task {
			await viewModel.onLoad()
		}
		.onChange(of: viewModel.didFinish) { _, didFinish in
			if didFinish { dismiss() }
		}
		.overlay {
			OverlayCircularProgressView(show: viewModel.isAdding)
		}
		.baseAlert(
			isPresented: $viewModel.isAddErrorPresented,
			type: .error,
			title: "Couldn't Add Currency",
			message: viewModel.addErrorMessage,
			confirmLabel: Text("OK"),
			confirmAction: {}
		)
	}

	private var searchField: some View {
		HStack(spacing: 8) {
			Image(systemName: "magnifyingglass")
				.foregroundStyle(.neutral60)

			TextField("Search currency or country", text: $viewModel.searchText)
				.font(.baseStyle(size: 15, weight: .regular))
				.autocorrectionDisabled(true)
				.textInputAutocapitalization(.never)
		}
		.padding(.horizontal, 14)
		.padding(.vertical, 10)
		.background(Capsule().fill(Color.moreSectionCardBackground))
		.padding(.horizontal, 16)
		.padding(.top, 12)
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.viewState {
		case .initial, .loading:
			ProgressView()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
		case .error:
			ContentUnavailableView(
				"Couldn't load currencies",
				systemImage: "dollarsign.circle",
				description: Text("Please try again later.")
			)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		case .loaded:
			ScrollView {
				VStack(alignment: .leading, spacing: 4) {
					Text("ALL CURRENCIES")
						.font(.baseStyle(size: 12, weight: .bold))
						.tracking(0.6)
						.foregroundStyle(.neutral60)
						.padding(.horizontal, 4)
						.padding(.top, 12)

					VStack(spacing: 0) {
						ForEach(Array(viewModel.filteredCurrencies.enumerated()), id: \.element) { index, currency in
							if index > 0 {
								Rectangle()
									.fill(.moreHairline.opacity(0.2))
									.frame(height: 1)
							}

							CatalogCurrencyRow(
								currency: currency,
								isAdded: viewModel.isAdded(currency),
								onTap: { viewModel.select(currency) }
							)
						}
					}
					.background(RoundedRectangle(cornerRadius: 12).fill(Color.moreSectionCardBackground))
				}
				.padding(16)
			}
		}
	}
}

private struct CatalogCurrencyRow: View {
	let currency: Currency.Response.CurrencyItem
	let isAdded: Bool
	let onTap: () -> Void

	var body: some View {
		Button(action: onTap) {
			HStack(spacing: 12) {
				CurrencyAvatarView(currency: currency, backgroundColor: .neutral40, foregroundColor: .neutral90, diameter: 40)

				VStack(alignment: .leading, spacing: 2) {
					Text(currency.name ?? "")
						.font(.baseStyle(size: 15, weight: .semibold))
						.foregroundStyle(.neutral100)

					Text(currency.code ?? "")
						.font(.baseStyle(size: 13, weight: .regular))
						.foregroundStyle(.neutral60)
				}

				Spacer()

				if isAdded {
					Image(systemName: "checkmark.circle.fill")
						.foregroundStyle(.brandPrimary)
				}
			}
			.padding(14)
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
		.disabled(isAdded)
	}
}

private final class PreviewUserCurrencyMutationDelegate: UserCurrencyMutationDelegate {
	func userCurrencyDidChange() {}
}

#Preview {
	NavigationStack {
		CurrencyCatalogPickerView(alreadyAddedCurrencyIds: ["usd"], delegate: PreviewUserCurrencyMutationDelegate())
	}
}
