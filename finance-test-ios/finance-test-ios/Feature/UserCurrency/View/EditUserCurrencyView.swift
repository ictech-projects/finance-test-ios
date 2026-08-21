//
//  EditUserCurrencyView.swift
//  finance-test-ios
//

import SwiftUI

struct EditUserCurrencyView<Delegate: UserCurrencyMutationDelegate>: View {
	@StateObject private var viewModel: EditUserCurrencyViewModel
	@Environment(\.dismiss) private var dismiss

	init(displayItem: UserCurrencyDisplayItem, anchorCurrencyCode: String, delegate: Delegate) {
		_viewModel = StateObject(
			wrappedValue: EditUserCurrencyViewModel(
				displayItem: displayItem, anchorCurrencyCode: anchorCurrencyCode, delegate: delegate
			)
		)
	}

	var body: some View {
		VStack(spacing: 0) {
			TopBarView(title: "Edit Currency", onBackPressed: { dismiss() })

			ScrollView {
				VStack(alignment: .leading, spacing: 24) {
					activeCurrencyCard
					conversionSection
					lastUpdatedCard
				}
				.padding(16)
			}

			PrimaryButton(size: .large, backgroundColor: .brandPrimary, isDisabled: viewModel.isSaveDisabled, action: {
				Task { await viewModel.save() }
			}) {
				if viewModel.viewState == .saving {
					ProgressView().tint(.white)
				} else {
					Label("Save Changes", systemImage: "square.and.arrow.down")
				}
			}
			.padding(16)
		}
		.background(Color.splashSurface.ignoresSafeArea())
		.navigationBarHidden(true)
		.onChange(of: viewModel.didFinish) { _, didFinish in
			if didFinish { dismiss() }
		}
		.baseAlert(
			isPresented: $viewModel.isSaveErrorPresented,
			type: .error,
			title: "Couldn't Save",
			message: viewModel.saveErrorMessage,
			confirmLabel: Text("OK"),
			confirmAction: {}
		)
	}

	private var activeCurrencyCard: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("ACTIVE CURRENCY")
				.font(.baseStyle(size: 12, weight: .bold))
				.tracking(0.6)
				.foregroundStyle(.neutral60)

			HStack {
				VStack(alignment: .leading, spacing: 6) {
					Text(viewModel.currencyName)
						.font(.baseStyle(size: 20, weight: .bold))
						.foregroundStyle(.neutral100)

					HStack(spacing: 6) {
						Text(viewModel.currencyCode)
							.font(.baseStyle(size: 13, weight: .semibold))
							.foregroundStyle(.neutral60)
							.padding(.horizontal, 8)
							.padding(.vertical, 3)
							.background(Capsule().fill(Color.moreSectionCardBackground))

						Text(viewModel.currencySymbol)
							.font(.baseStyle(size: 14, weight: .semibold))
							.foregroundStyle(.brandPrimary)
					}
				}

				Spacer()
			}
		}
		.padding(16)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(RoundedRectangle(cornerRadius: 16).fill(Color.moreSectionCardBackground))
	}

	private var conversionSection: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Conversion Parameters")
				.font(.baseStyle(size: 16, weight: .bold))
				.foregroundStyle(.neutral100)

			Text("Update the exchange rate relative to your base currency (\(viewModel.anchorCurrencyCode)).")
				.font(.baseStyle(size: 13, weight: .regular))
				.foregroundStyle(.neutral60)

			TextField("0.00", text: $viewModel.exchangeRateText)
				.withTitle(Text("Exchange Rate"), keyboardType: .decimalPad)
		}
	}

	private var lastUpdatedCard: some View {
		HStack(spacing: 12) {
			Image(systemName: "clock.arrow.circlepath")
				.foregroundStyle(.neutral60)

			VStack(alignment: .leading, spacing: 2) {
				Text("Last Updated")
					.font(.baseStyle(size: 12, weight: .medium))
					.foregroundStyle(.neutral60)

				Text(viewModel.lastUpdatedLabel)
					.font(.baseStyle(size: 15, weight: .semibold))
					.foregroundStyle(.neutral100)
			}

			Spacer()
		}
		.padding(16)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(RoundedRectangle(cornerRadius: 16).fill(Color.moreSectionCardBackground))
	}
}

private final class PreviewUserCurrencyMutationDelegate: UserCurrencyMutationDelegate {
	func userCurrencyDidChange() {}
}

#Preview {
	NavigationStack {
		EditUserCurrencyView(
			displayItem: UserCurrencyDisplayItem(
				item: UserCurrency.Response.UserCurrencyItem.mocks[1],
				currency: Currency.Response.CurrencyItem.mocks[1]
			),
			anchorCurrencyCode: "USD",
			delegate: PreviewUserCurrencyMutationDelegate()
		)
	}
}
