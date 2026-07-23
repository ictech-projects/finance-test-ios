//
//  CurrencySelectionViewModel.swift
//  finance-test-ios
//

import Combine
import Foundation

@MainActor
protocol CurrencySelectionDelegate: AnyObject {
	func didSelectCurrency(_ currency: Currency)
}

@MainActor
final class CurrencySelectionViewModel: ObservableObject {
	@Published var currencies: [Currency]
	@Published var selectedCurrency: Currency

	private let delegate: any CurrencySelectionDelegate

	init(
		currencies: [Currency] = Currency.mocks,
		selectedCurrency: Currency = .usd,
		delegate: some CurrencySelectionDelegate
	) {
		self.currencies = currencies
		self.selectedCurrency = selectedCurrency
		self.delegate = delegate
	}

	func select(_ currency: Currency) {
		selectedCurrency = currency
	}

	func confirmSelection() {
		delegate.didSelectCurrency(selectedCurrency)
	}
}
