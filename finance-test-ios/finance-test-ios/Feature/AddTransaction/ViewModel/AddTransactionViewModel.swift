//
//  AddTransactionViewModel.swift
//  finance-test-ios
//

import Combine
import Foundation
import SwiftUI

@MainActor
protocol AddTransactionDelegate: AnyObject {
	func didCreateTransaction(_ item: TransactionRecord.Response.TransactionItem)
}

/// A key on the calculator-style keypad used to enter the transaction amount.
enum NumericKeypadKey: Hashable {
	case digit(Int)
	case decimalPoint
	case delete
}

@MainActor
final class AddTransactionViewModel: ObservableObject {
	enum ViewState: Equatable {
		case initial
		case loading
		case loaded
		case error
	}

	@Published private(set) var viewState = ViewState.initial
	@Published private(set) var type = TransactionType.expense
	@Published var amountText = ""
	@Published var note = ""
	@Published var date = Date()
	@Published private(set) var selectedAccount: Account.Response.AccountItem?
	@Published private(set) var selectedCategory: TransactionCategory.Response.CategoryItem?
	@Published private(set) var accounts: [Account.Response.AccountItem] = []
	@Published private(set) var categories: [TransactionCategory.Response.CategoryItem] = []
	@Published var isDatePickerPresented = false
	@Published var isAccountPickerPresented = false
	@Published var amountErrorMessage: String?
	@Published var accountErrorMessage: String?
	@Published var categoryErrorMessage: String?
	@Published private(set) var isSaving = false
	@Published var isSaveErrorPresented = false
	@Published private(set) var saveErrorMessage = ""

	private let transactionRepository: any TransactionRepository
	private let categoryRepository: any TransactionCategoryRepository
	private let accountRepository: any AccountRepository
	private let delegate: any AddTransactionDelegate

	init(
		date: Date = Date(),
		transactionRepository: some TransactionRepository = TransactionMockRepository(),
		categoryRepository: some TransactionCategoryRepository = TransactionCategoryMockRepository(),
		accountRepository: some AccountRepository = AccountMockRepository(),
		delegate: some AddTransactionDelegate
	) {
		self.date = date
		self.transactionRepository = transactionRepository
		self.categoryRepository = categoryRepository
		self.accountRepository = accountRepository
		self.delegate = delegate
	}

	var categoriesForCurrentType: [TransactionCategory.Response.CategoryItem] {
		categories.filter { $0.type == type }
	}

	var isSaveDisabled: Bool {
		isSaving
	}

	func onLoad() async {
		viewState = .loading

		async let categoriesState = categoryRepository.getCategories(request: .init(type: nil, since: nil))
		async let accountsState = accountRepository.getAccounts(request: .init(since: nil))

		do {
			let (loadedCategories, loadedAccounts) = try await (categoriesState, accountsState)

			guard
				case .loaded(let categoriesResponse) = loadedCategories,
				case .loaded(let accountsResponse) = loadedAccounts
			else {
				viewState = .error
				return
			}

			categories = categoriesResponse.data?.items ?? []
			accounts = accountsResponse.data?.items ?? []
			selectedAccount = accounts.first(where: { $0.isDefault == true }) ?? accounts.first
			selectDefaultCategoryIfNeeded()
			viewState = .loaded
		} catch {
			viewState = .error
		}
	}

	func selectType(_ newType: TransactionType) {
		guard newType != type else { return }
		withAnimation(.easeInOut(duration: 0.2)) {
			type = newType
			selectDefaultCategoryIfNeeded()
		}
	}

	func presentAccountPicker() {
		withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
			isAccountPickerPresented = true
		}
	}

	func presentDatePicker() {
		withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
			isDatePickerPresented = true
		}
	}

	func selectAccount(_ account: Account.Response.AccountItem) {
		selectedAccount = account
		accountErrorMessage = nil
		withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
			isAccountPickerPresented = false
		}
	}

	func selectCategory(_ category: TransactionCategory.Response.CategoryItem) {
		withAnimation(.easeInOut(duration: 0.15)) {
			selectedCategory = category
		}
		categoryErrorMessage = nil
	}

	func dismissDatePicker() {
		withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
			isDatePickerPresented = false
		}
	}

	/// Handles a tap on the calculator-style numeric keypad — the amount has no system keyboard,
	/// per the Figma design (`Numeric Display` + `Overlay+OverlayBlur` keypad grid).
	func handleKeypadInput(_ key: NumericKeypadKey) {
		switch key {
		case .digit(let digit):
			appendToAmount(String(digit))
		case .decimalPoint:
			guard !amountText.contains(".") else { return }
			appendToAmount(amountText.isEmpty ? "0." : ".")
		case .delete:
			guard !amountText.isEmpty else { return }
			amountText.removeLast()
		}

		if amountErrorMessage != nil {
			withAnimation(.easeOut(duration: 0.2)) {
				amountErrorMessage = nil
			}
		}
	}

	private func appendToAmount(_ characters: String) {
		if let dotIndex = amountText.firstIndex(of: "."),
			amountText.distance(from: dotIndex, to: amountText.endIndex) > 2 {
			return
		}
		amountText += characters
	}

	func save() async {
		guard let request = validatedRequest() else { return }

		isSaving = true

		do {
			let state = try await transactionRepository.createTransaction(request: request)
			switch state {
			case .loaded(let response):
				isSaving = false
				if let item = response.data {
					delegate.didCreateTransaction(item)
				}
			case .error(let error):
				handleSaveError(error)
			default:
				isSaving = false
			}
		} catch {
			handleSaveError(error)
		}
	}

	// MARK: - Private

	private func selectDefaultCategoryIfNeeded() {
		guard selectedCategory == nil || selectedCategory?.type != type else { return }
		selectedCategory = categoriesForCurrentType.first
	}

	private func validatedRequest() -> TransactionRecord.Request.CreateTransaction? {
		amountErrorMessage = nil
		accountErrorMessage = nil
		categoryErrorMessage = nil
		var hasError = false

		let normalizedAmount = amountText.trimmingCharacters(in: .whitespaces)
		let amountValue = Double(normalizedAmount)

		if normalizedAmount.isEmpty {
			amountErrorMessage = String(localized: "Please enter an amount.")
			hasError = true
		} else if amountValue == nil || amountValue! <= 0 {
			amountErrorMessage = String(localized: "Please enter a valid amount.")
			hasError = true
		}

		if selectedAccount == nil {
			accountErrorMessage = String(localized: "Please select an account.")
			hasError = true
		}

		if selectedCategory == nil {
			categoryErrorMessage = String(localized: "Please select a category.")
			hasError = true
		}

		guard
			!hasError,
			let amountValue,
			let accountId = selectedAccount?.id,
			let categoryId = selectedCategory?.id
		else {
			return nil
		}

		return TransactionRecord.Request.CreateTransaction(
			accountId: accountId,
			categoryId: categoryId,
			type: type,
			amount: String(format: "%.2f", amountValue),
			exchangeRateToAnchor: "1",
			description: note.isEmpty ? nil : note,
			transactionDate: Self.wireDateFormatter.string(from: date)
		)
	}

	private func handleSaveError(_ error: Error) {
		isSaving = false

		if let errorResponse = error as? ErrorResponse {
			saveErrorMessage = errorResponse.message ?? String(localized: "Something went wrong. Please try again.")
		} else {
			saveErrorMessage = String(localized: "Something went wrong. Please try again.")
		}

		withAnimation(.easeOut(duration: 0.2)) {
			isSaveErrorPresented = true
		}
	}

	private static let wireDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(identifier: "UTC")
		return formatter
	}()
}
