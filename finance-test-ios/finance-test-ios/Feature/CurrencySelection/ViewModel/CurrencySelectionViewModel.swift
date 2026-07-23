//
//  CurrencySelectionViewModel.swift
//  finance-test-ios
//

import Combine
import Foundation
import SwiftUI

@MainActor
protocol CurrencySelectionDelegate: AnyObject {
	func didSelectCurrency(_ currency: Currency.Response.CurrencyItem)
}

@MainActor
final class CurrencySelectionViewModel: ObservableObject {
	enum ViewState {
		case initial
		case loading
		case loaded
		case error
	}

	@Published var viewState = ViewState.initial
	@Published var currencies: [Currency.Response.CurrencyItem] = []
	@Published var selectedCurrency: Currency.Response.CurrencyItem

	private let currencyRepository: any CurrencyRepository
	private let delegate: any CurrencySelectionDelegate

	init(
		selectedCurrency: Currency.Response.CurrencyItem = .usd,
		currencyRepository: some CurrencyRepository = CurrencyMockRepository(),
		delegate: some CurrencySelectionDelegate
	) {
		self.selectedCurrency = selectedCurrency
		self.currencyRepository = currencyRepository
		self.delegate = delegate
	}

	func onLoad() async {
		await loadCurrencies()
	}

	private func loadCurrencies() async {
		viewState = .loading

		do {
			let state = try await currencyRepository.getCurrencies(request: .init(since: nil))
			switch state {
			case .loaded(let response):
				currencies = response.data?.items ?? []
				viewState = .loaded
			case .error:
				viewState = .error
			default:
				break
			}
		} catch {
			viewState = .error
		}
	}

	func select(_ currency: Currency.Response.CurrencyItem) {
		withAnimation(.easeInOut(duration: 0.2)) {
			selectedCurrency = currency
		}
	}

	func confirmSelection() {
		delegate.didSelectCurrency(selectedCurrency)
	}
}
