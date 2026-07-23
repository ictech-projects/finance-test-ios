//
//  CurrencySelectionDialogView.swift
//  finance-test-ios
//

import SwiftUI

struct CurrencySelectionDialogView<Delegate: CurrencySelectionDelegate>: View {
	@StateObject private var viewModel: CurrencySelectionViewModel

	init(delegate: Delegate) {
		_viewModel = StateObject(wrappedValue: CurrencySelectionViewModel(delegate: delegate))
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 20) {
			VStack(alignment: .leading, spacing: 6) {
				Text("Select Currency")
					.font(.baseStyle(size: 20, weight: .bold))
					.foregroundStyle(.neutral100)

				Text("Please choose your primary currency to get started.")
					.font(.baseStyle(size: 13, weight: .regular))
					.foregroundStyle(.neutral60)
			}

			switch viewModel.viewState {
			case .initial, .loading:
				ProgressView()
					.frame(maxWidth: .infinity)
					.padding(.vertical, 24)
			case .loaded:
				VStack(spacing: 4) {
					ForEach(viewModel.currencies, id: \.self) { currency in
						CurrencyRow(
							currency: currency,
							isSelected: currency == viewModel.selectedCurrency,
							onTap: { viewModel.select(currency) }
						)
					}
				}
			case .error:
				Text("Couldn't load currencies. Please try again.")
					.font(.baseStyle(size: 13, weight: .regular))
					.foregroundStyle(.neutral60)
			}

			PrimaryButton(size: .large, backgroundColor: .brandPrimary, action: viewModel.confirmSelection) {
				Text("Confirm")
			}
		}
		.padding(24)
		.background(Color(.systemBackground))
		.clipShape(RoundedRectangle(cornerRadius: 24))
		.task {
			await viewModel.onLoad()
		}
	}
}

private final class PreviewCurrencySelectionDelegate: CurrencySelectionDelegate {
	func didSelectCurrency(_ currency: Currency.Response.CurrencyItem) {}
}

#Preview {
	ZStack {
		Color.black.opacity(0.75).ignoresSafeArea()
		CurrencySelectionDialogView(delegate: PreviewCurrencySelectionDelegate())
			.padding(24)
	}
}
