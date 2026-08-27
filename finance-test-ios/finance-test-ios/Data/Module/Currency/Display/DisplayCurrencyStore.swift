//
//  DisplayCurrencyStore.swift
//  finance-test-ios
//

import Combine
import Foundation

/// Single source of truth for the currency amounts are displayed in.
///
/// Resolved from the user's **anchor** currency (`is_anchor`), which is what the backend already
/// treats as the base currency — exchange rates are quoted against it, and new accounts are
/// stamped with it. This store only ever *reads* the anchor: changing it re-bases the meaning of
/// every stored exchange rate, so it is not a display toggle.
///
/// `Double.currencyFormatted` reads `shared.current` as a default argument, so plain Views with no
/// ViewModel (`AnimatedAmountText`, `AccountsListView`'s row) format correctly without threading
/// currency through them — the same reason `AuthDefaultSessionStore.shared` is reachable directly.
/// It is also an `ObservableObject` so Views can re-render when it resolves.
@MainActor
protocol DisplayCurrencyStore: AnyObject {
	var current: DisplayCurrency { get }
	var currentPublisher: AnyPublisher<DisplayCurrency, Never> { get }
	/// Loads the anchor currency. Safe to call repeatedly; leaves `current` untouched on failure.
	func refresh() async
}

@MainActor
final class DisplayCurrencyDefaultStore: DisplayCurrencyStore, ObservableObject {

	static let shared = DisplayCurrencyDefaultStore()

	/// Mirrored into `DisplayCurrency.current` on every change so the synchronous formatter — and
	/// therefore plain Views with no ViewModel — sees the same value.
	@Published private(set) var current: DisplayCurrency {
		didSet { DisplayCurrency.setCurrent(current) }
	}

	var currentPublisher: AnyPublisher<DisplayCurrency, Never> {
		$current.eraseToAnyPublisher()
	}

	private let userCurrencyRepository: any UserCurrencyRepository
	private let currencyRepository: any CurrencyRepository

	init(
		userCurrencyRepository: some UserCurrencyRepository = UserCurrencyDefaultRepository(),
		currencyRepository: some CurrencyRepository = CurrencyDefaultRepository(),
		current: DisplayCurrency = .fallback
	) {
		self.userCurrencyRepository = userCurrencyRepository
		self.currencyRepository = currencyRepository
		self.current = current
		// `didSet` doesn't fire from an initializer, so seed the mirror explicitly.
		DisplayCurrency.setCurrent(current)
	}

	/// `UserCurrencyResource` carries only a `currency_id`, so the symbol has to be joined from
	/// the catalog — the same two-call join `UserCurrenciesViewModel` does.
	func refresh() async {
		async let userCurrenciesState = userCurrencyRepository.getUserCurrencies(request: .init(since: nil))
		async let currenciesState = currencyRepository.getCurrencies(request: .init(since: nil))

		guard
			let (userResult, catalogResult) = try? await (userCurrenciesState, currenciesState),
			case .loaded(let userResponse) = userResult,
			case .loaded(let catalogResponse) = catalogResult
		else {
			return
		}

		let userCurrencies = userResponse.data?.items ?? []
		let catalog = catalogResponse.data?.items ?? []

		// `?? .first` mirrors `AccountFormViewModel`'s anchor resolution: a user whose currencies
		// predate the anchor flag has none marked, and the first is the best available guess.
		guard
			let anchor = userCurrencies.first(where: { $0.isAnchor == true }) ?? userCurrencies.first,
			let match = catalog.first(where: { $0.id == anchor.currencyId })
		else {
			return
		}

		current = DisplayCurrency(item: match)
	}
}
