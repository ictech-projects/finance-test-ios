//
//  AddExpenseIntentHandler.swift
//  finance-test-ios
//

import Foundation

/// The result of a successful `AddExpenseIntentHandler.addExpense` call — carries everything
/// `AddExpenseSnippetView` needs to render the created record, so the Siri card can show the
/// transaction rather than restating the spoken confirmation.
struct AddExpenseResult: Equatable {
	let amount: Double
	let categoryName: String
	/// Already resolved to a real SF Symbol via `CategoryIconResolver`.
	let categoryIcon: String
	let categoryColorHex: String?
	let accountName: String
	/// The merchant/note, when the caller gave one. `nil` collapses that line in the snippet.
	let note: String?
}

/// Core logic behind `AddExpenseIntent`, split out so it's testable the same way this codebase
/// tests ViewModels (Swift Testing + mock repositories) - `AppIntent.perform()` itself isn't.
struct AddExpenseIntentHandler {
	private let transactionRepository: any TransactionRepository
	private let accountRepository: any AccountRepository
	private let categoryRepository: any UserCategoryRepository
	private let authLocalDataSource: any AuthLocalDataSource
	private let displayCurrencyStore: any DisplayCurrencyStore

	private let now: () -> Date

	init(
		transactionRepository: some TransactionRepository = TransactionDefaultRepository(),
		accountRepository: some AccountRepository = AccountDefaultRepository(),
		categoryRepository: some UserCategoryRepository = UserCategoryDefaultRepository(),
		authLocalDataSource: some AuthLocalDataSource = AuthDefaultLocalDataSource(),
		displayCurrencyStore: any DisplayCurrencyStore = DisplayCurrencyDefaultStore.shared,
		now: @escaping () -> Date = Date.init
	) {
		self.transactionRepository = transactionRepository
		self.accountRepository = accountRepository
		self.categoryRepository = categoryRepository
		self.authLocalDataSource = authLocalDataSource
		self.displayCurrencyStore = displayCurrencyStore
		self.now = now
	}

	/// Mirrors `AddTransactionViewModel`'s default-resolution (`isDefault` account, first
	/// matching-type category) so a Siri/Shortcuts-created expense behaves like one made in the
	/// app when the caller didn't pick an account/category explicitly.
	func addExpense(
		amount: Double,
		merchant: String?,
		accountId: String?,
		categoryId: String?
	) async throws -> AddExpenseResult {
		guard authLocalDataSource.getAccessToken() != nil else {
			throw FinanceIntentError.notLoggedIn
		}
		guard amount > 0 else {
			throw FinanceIntentError.invalidAmount
		}

		async let accountsState = accountRepository.getAccounts(request: .init(since: nil))
		async let categoriesState = categoryRepository.getUserCategories()
		// A Siri-only launch never shows `LaunchScreenView`, so nothing else resolves the display
		// currency — without this the dialog and snippet would fall back to "$" for every user.
		// Fire-and-forget: a failure leaves the previous currency, which formatting handles.
		async let currencyRefresh: Void = displayCurrencyStore.refresh()

		let (accountsResult, categoriesResult) = try await (accountsState, categoriesState)
		await currencyRefresh

		let accounts = try Self.items(from: accountsResult) { $0.items }
		// A transaction's `category_id` must reference the user's own category, not the global
		// `/categories` catalog. `getUserCategories()` takes no type filter and `/sync/pull`
		// includes soft-deleted tombstones, so both are narrowed here.
		let categories = try Self.items(from: categoriesResult) { $0 }
			.filter { $0.type == .expense && $0.deletedAt == nil }

		let resolvedAccount = accountId.flatMap { id in accounts.first { $0.id == id } }
			?? accounts.first(where: { $0.isDefault == true })
			?? accounts.first

		guard let account = resolvedAccount, let accountIdValue = account.id else {
			throw FinanceIntentError.noAccountAvailable
		}

		// Unlike accounts, categories have no backend `isDefault`, so there is no meaningful
		// default to fall back on — silently substituting one mis-files the expense under a
		// category the user never chose. An explicitly requested category must actually match.
		let resolvedCategory: Sync.Response.UserCategoryItem?
		if let categoryId {
			guard let match = categories.first(where: { $0.id == categoryId }) else {
				throw FinanceIntentError.categoryNotFound
			}
			resolvedCategory = match
		} else {
			resolvedCategory = categories.first
		}

		guard let category = resolvedCategory, let categoryIdValue = category.id else {
			throw FinanceIntentError.noCategoryAvailable
		}

		let trimmedMerchant = merchant?.trimmingCharacters(in: .whitespaces)

		let request = TransactionRecord.Request.CreateTransaction(
			accountId: accountIdValue,
			categoryId: categoryIdValue,
			type: .expense,
			amount: String(format: "%.2f", amount),
			exchangeRateToAnchor: "1",
			description: (trimmedMerchant?.isEmpty ?? true) ? nil : trimmedMerchant,
			transactionDate: Self.wireDateFormatter.string(from: now())
		)

		let state = try await transactionRepository.createTransaction(request: request)

		guard case .loaded = state else {
			throw Self.error(from: state)
		}

		let note = (trimmedMerchant?.isEmpty ?? true) ? nil : trimmedMerchant

		return AddExpenseResult(
			amount: amount,
			categoryName: category.name ?? String(localized: "expense"),
			categoryIcon: CategoryIconResolver.symbol(for: category.icon),
			categoryColorHex: category.color,
			accountName: account.name ?? String(localized: "Unknown Account"),
			note: note
		)
	}

	/// Unwraps a `.loaded` list response's items, or throws the right `FinanceIntentError` for
	/// `.error`/any other state - shared by the accounts and categories fetches above.
	private static func items<Response, Item>(
		from state: RequestState<GeneralResponse<Response>>,
		items: (Response) -> [Item]?
	) throws -> [Item] {
		guard case .loaded(let response) = state else {
			throw error(from: state)
		}
		return response.data.flatMap(items) ?? []
	}

	private static func error<T>(from state: RequestState<T>) -> FinanceIntentError {
		if case .error(let error) = state {
			return .from(error)
		}
		return .requestFailed(message: String(localized: "Something went wrong. Please try again."))
	}

	private static let wireDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(identifier: "UTC")
		return formatter
	}()
}
