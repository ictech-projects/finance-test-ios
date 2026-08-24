//
//  UserCurrenciesViewModel.swift
//  finance-test-ios
//

import Combine
import Foundation

/// Lets `EditUserCurrencyViewModel`/`CurrencyCatalogPickerViewModel` report back that the user's
/// currency list changed, without holding a reference back to the concrete list view model.
@MainActor
protocol UserCurrencyMutationDelegate: AnyObject {
	func userCurrencyDidChange()
}

@MainActor
final class UserCurrenciesViewModel: ObservableObject {
	enum ViewState: Equatable {
		case initial
		case loading
		case loaded
		case error
	}

	@Published private(set) var viewState = ViewState.initial
	@Published private(set) var rows: [UserCurrencyDisplayItem] = []

	private let userCurrencyRepository: any UserCurrencyRepository
	private let currencyRepository: any CurrencyRepository

	init(
		userCurrencyRepository: some UserCurrencyRepository = UserCurrencyDefaultRepository(),
		currencyRepository: some CurrencyRepository = CurrencyDefaultRepository()
	) {
		self.userCurrencyRepository = userCurrencyRepository
		self.currencyRepository = currencyRepository
	}

	var addedCurrencyIds: Set<String> {
		Set(rows.compactMap(\.item.currencyId))
	}

	/// The currency code exchange rates are quoted against — whichever user currency is marked
	/// `is_anchor`. Falls back to "—" before load / if none is marked yet.
	var anchorCurrencyCode: String {
		rows.first(where: { $0.item.isAnchor == true })?.currency?.code ?? "—"
	}

	func onLoad() async {
		viewState = .loading

		async let userCurrenciesState = userCurrencyRepository.getUserCurrencies(request: .init(since: nil))
		async let currenciesState = currencyRepository.getCurrencies(request: .init(since: nil))

		do {
			let (userCurrenciesResult, currenciesResult) = try await (userCurrenciesState, currenciesState)

			guard
				case .loaded(let userCurrenciesResponse) = userCurrenciesResult,
				case .loaded(let currenciesResponse) = currenciesResult
			else {
				viewState = .error
				return
			}

			let currenciesById = Dictionary(
				(currenciesResponse.data?.items ?? []).compactMap { currency in currency.id.map { ($0, currency) } },
				uniquingKeysWith: { first, _ in first }
			)

			rows = (userCurrenciesResponse.data?.items ?? [])
				.map { item in
					UserCurrencyDisplayItem(item: item, currency: item.currencyId.flatMap { currenciesById[$0] })
				}
				.sorted { ($0.item.isAnchor ?? false) && !($1.item.isAnchor ?? false) }
			viewState = .loaded
		} catch {
			viewState = .error
		}
	}
}

extension UserCurrenciesViewModel: UserCurrencyMutationDelegate {
	func userCurrencyDidChange() {
		Task { await onLoad() }
	}
}
