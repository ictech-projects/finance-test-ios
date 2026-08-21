//
//  CurrencyCatalogPickerViewModel.swift
//  finance-test-ios
//

import Combine
import Foundation

@MainActor
final class CurrencyCatalogPickerViewModel: ObservableObject {
	enum ViewState: Equatable {
		case initial
		case loading
		case loaded
		case error
	}

	@Published private(set) var viewState = ViewState.initial
	@Published private(set) var currencies: [Currency.Response.CurrencyItem] = []
	@Published var searchText = ""
	@Published private(set) var isAdding = false
	@Published private(set) var didFinish = false
	@Published var isAddErrorPresented = false
	@Published private(set) var addErrorMessage = ""

	private let alreadyAddedCurrencyIds: Set<String>
	private let currencyRepository: any CurrencyRepository
	private let userCurrencyRepository: any UserCurrencyRepository
	private let delegate: any UserCurrencyMutationDelegate

	init(
		alreadyAddedCurrencyIds: Set<String>,
		currencyRepository: some CurrencyRepository = CurrencyDefaultRepository(),
		userCurrencyRepository: some UserCurrencyRepository = UserCurrencyDefaultRepository(),
		delegate: some UserCurrencyMutationDelegate
	) {
		self.alreadyAddedCurrencyIds = alreadyAddedCurrencyIds
		self.currencyRepository = currencyRepository
		self.userCurrencyRepository = userCurrencyRepository
		self.delegate = delegate
	}

	var filteredCurrencies: [Currency.Response.CurrencyItem] {
		let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
		guard !query.isEmpty else { return currencies }

		return currencies.filter {
			($0.code?.lowercased().contains(query) ?? false) || ($0.name?.lowercased().contains(query) ?? false)
		}
	}

	func isAdded(_ currency: Currency.Response.CurrencyItem) -> Bool {
		guard let id = currency.id else { return false }
		return alreadyAddedCurrencyIds.contains(id)
	}

	func onLoad() async {
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
		guard !isAdding, !isAdded(currency), let currencyId = currency.id else { return }
		isAdding = true

		Task {
			do {
				let state = try await userCurrencyRepository.createUserCurrency(
					request: .init(currencyId: currencyId, exchangeRate: nil, isAnchor: nil)
				)
				switch state {
				case .loaded:
					delegate.userCurrencyDidChange()
					didFinish = true
				case .error(let error):
					handleAddError(error)
				default:
					isAdding = false
				}
			} catch {
				handleAddError(error)
			}
		}
	}

	private func handleAddError(_ error: Error) {
		isAdding = false
		addErrorMessage = (error as? ErrorResponse)?.message ?? String(localized: "Something went wrong. Please try again.")
		isAddErrorPresented = true
	}
}
