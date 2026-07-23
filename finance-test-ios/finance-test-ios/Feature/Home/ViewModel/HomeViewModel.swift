//
//  HomeViewModel.swift
//  finance-test-ios
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
	@Published var summary: HomeSummary
	@Published var transactions: [TransactionItem]
	@Published var categories: [SpendingCategory]
	@Published var selectedCurrency: Currency
	@Published var isCurrencyDialogPresented = false

	init(
		summary: HomeSummary = .mock,
		transactions: [TransactionItem] = TransactionItem.mocks,
		categories: [SpendingCategory] = SpendingCategory.mocks,
		selectedCurrency: Currency = .usd
	) {
		self.summary = summary
		self.transactions = transactions
		self.categories = categories
		self.selectedCurrency = selectedCurrency
	}

	func presentCurrencySelection() {
		withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
			isCurrencyDialogPresented = true
		}
	}
}

extension HomeViewModel: CurrencySelectionDelegate {
	func didSelectCurrency(_ currency: Currency) {
		selectedCurrency = currency
		withAnimation(.easeInOut(duration: 0.25)) {
			isCurrencyDialogPresented = false
		}
	}
}
