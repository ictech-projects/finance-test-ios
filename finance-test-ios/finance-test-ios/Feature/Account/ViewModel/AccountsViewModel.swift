//
//  AccountsViewModel.swift
//  finance-test-ios
//

import Combine
import Foundation

/// Lets `AccountFormViewModel` report back that the account list changed, without holding a
/// reference back to the concrete list view model.
@MainActor
protocol AccountMutationDelegate: AnyObject {
	func accountDidChange()
}

@MainActor
final class AccountsViewModel: ObservableObject {
	enum ViewState: Equatable {
		case initial
		case loading
		case loaded
		case error
	}

	@Published private(set) var viewState = ViewState.initial
	@Published private(set) var accounts: [Account.Response.AccountItem] = []

	private let accountRepository: any AccountRepository

	init(accountRepository: some AccountRepository = AccountDefaultRepository()) {
		self.accountRepository = accountRepository
	}

	func onLoad() async {
		viewState = .loading

		do {
			let state = try await accountRepository.getAccounts(request: .init(since: nil))

			guard case .loaded(let response) = state else {
				viewState = .error
				return
			}

			accounts = response.data?.items ?? []
			viewState = .loaded
		} catch {
			viewState = .error
		}
	}
}

extension AccountsViewModel: AccountMutationDelegate {
	func accountDidChange() {
		Task { await onLoad() }
	}
}
