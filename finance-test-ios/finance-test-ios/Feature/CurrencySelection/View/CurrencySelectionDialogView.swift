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

			VStack(spacing: 4) {
				ForEach(viewModel.currencies) { currency in
					CurrencyRow(
						currency: currency,
						isSelected: currency == viewModel.selectedCurrency,
						onTap: { viewModel.select(currency) }
					)
				}
			}

			PrimaryButton(size: .large, action: viewModel.confirmSelection) {
				Text("Confirm")
			}
		}
		.padding(24)
		.background(Color(.systemBackground))
		.clipShape(RoundedRectangle(cornerRadius: 24))
	}
}

private final class PreviewCurrencySelectionDelegate: CurrencySelectionDelegate {
	func didSelectCurrency(_ currency: Currency) {}
}

#Preview {
	ZStack {
		Color.black.opacity(0.75).ignoresSafeArea()
		CurrencySelectionDialogView(delegate: PreviewCurrencySelectionDelegate())
			.padding(24)
	}
}
