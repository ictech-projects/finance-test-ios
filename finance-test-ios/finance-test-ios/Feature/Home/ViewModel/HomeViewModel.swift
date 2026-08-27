//
//  HomeViewModel.swift
//  finance-test-ios
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
	enum ViewState: Equatable {
		case initial
		case loading
		case loaded
		case error
	}

	@Published private(set) var viewState = ViewState.initial
	@Published private(set) var summary = HomeSummary.empty
	@Published private(set) var transactions: [TransactionItem] = []
	@Published private(set) var categories: [SpendingCategory] = []
	@Published private(set) var profile: Auth.Response.User?
	@Published var selectedCurrency: Currency.Response.CurrencyItem
	@Published var isCurrencyDialogPresented = false

	private let transactionRepository: any TransactionRepository
	private let categoryRepository: any UserCategoryRepository
	private let accountRepository: any AccountRepository
	private let authRepository: any AuthRepository

	private static let recentTransactionsLimit = 5

	init(
		transactionRepository: some TransactionRepository = TransactionDefaultRepository(),
		categoryRepository: some UserCategoryRepository = UserCategoryDefaultRepository(),
		accountRepository: some AccountRepository = AccountDefaultRepository(),
		authRepository: some AuthRepository = AuthDefaultRepository(),
		selectedCurrency: Currency.Response.CurrencyItem = .usd
	) {
		self.transactionRepository = transactionRepository
		self.categoryRepository = categoryRepository
		self.accountRepository = accountRepository
		self.authRepository = authRepository
		self.selectedCurrency = selectedCurrency
	}

	func presentCurrencySelection() {
		withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
			isCurrencyDialogPresented = true
		}
	}

	/// Lets `ProfileView` push a freshly saved name/avatar back into the header without a
	/// re-fetch, via a plain closure rather than a shared delegate object.
	func profileDidUpdate(_ user: Auth.Response.User) {
		profile = user
	}

	func onLoad() async {
		viewState = .loading

		async let transactionsState = transactionRepository.getTransactions(request: .init(since: nil))
		async let categoriesState = categoryRepository.getUserCategories()
		async let accountsState = accountRepository.getAccounts(request: .init(since: nil))
		async let profileState = authRepository.getProfile()

		do {
			let (transactionsResult, categoriesResult, accountsResult, profileResult) = try await (
				transactionsState, categoriesState, accountsState, profileState
			)

			// The header's avatar/name are a nice-to-have, not core to the dashboard - a failed
			// profile fetch falls back to the placeholder rather than failing the whole screen.
			if case .loaded(let profileResponse) = profileResult {
				profile = profileResponse.data?.user
			}

			guard
				case .loaded(let transactionsResponse) = transactionsResult,
				case .loaded(let categoriesResponse) = categoriesResult,
				case .loaded(let accountsResponse) = accountsResult
			else {
				viewState = .error
				return
			}

			let allTransactions = transactionsResponse.data?.items ?? []
			let allCategories = (categoriesResponse.data ?? []).filter { $0.deletedAt == nil }
			let allAccounts = accountsResponse.data?.items ?? []
			let resolver = CategoryAccountDisplayResolver(categories: allCategories, accounts: allAccounts)

			let thisMonthTransactions = allTransactions.filter(Self.isInCurrentMonth)
			let reportsSummary = ReportsAggregator.summarize(transactions: thisMonthTransactions, categories: allCategories)

			summary = HomeSummary(
				balanceThisMonth: reportsSummary.netAmount,
				netWorth: Self.netWorth(accounts: allAccounts),
				income: reportsSummary.totalIncome,
				expense: reportsSummary.totalExpense
			)
			categories = reportsSummary.expenseBreakdown.map { breakdown in
				SpendingCategory(
					name: breakdown.categoryName,
					percent: breakdown.percentage / 100,
					color: breakdown.colorHex.flatMap { Color(hex: $0) } ?? .neutral40
				)
			}
			transactions = allTransactions
				.sorted { ($0.createdAt ?? $0.transactionDate ?? "") > ($1.createdAt ?? $1.transactionDate ?? "") }
				.prefix(Self.recentTransactionsLimit)
				.compactMap { Self.makeTransactionItem(from: $0, resolver: resolver) }

			viewState = .loaded
		} catch {
			viewState = .error
		}
	}

	/// "Assets - Liabilities" (per `NetWorthCard`'s subtitle) with only an Accounts data layer
	/// available — there's no dedicated Liabilities module yet, so a `credit_card` account's
	/// balance (money owed on it) is treated as a liability and subtracted rather than summed
	/// as an asset like every other account type.
	private static func netWorth(accounts: [Account.Response.AccountItem]) -> Double {
		accounts.reduce(0) { partial, account in
			let balance = account.balance.flatMap(Double.init) ?? 0
			return partial + (account.type == "credit_card" ? -balance : balance)
		}
	}

	private static func isInCurrentMonth(_ item: TransactionRecord.Response.TransactionItem) -> Bool {
		guard let dateString = item.transactionDate, let date = dayFormatter.date(from: dateString) else { return false }
		return Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month)
	}

	private static func makeTransactionItem(
		from item: TransactionRecord.Response.TransactionItem,
		resolver: CategoryAccountDisplayResolver
	) -> TransactionItem? {
		guard
			let amountString = item.amount,
			let amount = Double(amountString),
			let type = item.type,
			let dateString = item.transactionDate,
			let date = dayFormatter.date(from: dateString)
		else { return nil }

		let category = resolver.category(for: item.categoryId)
		let account = resolver.account(for: item.accountId)
		let isCredit = type == .income

		return TransactionItem(
			title: category.name,
			merchant: item.description ?? "",
			amount: isCredit ? amount : -amount,
			account: account.name,
			dateLabel: dayLabelFormatter.string(for: date),
			iconName: category.icon
		)
	}

	private static let dayFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(identifier: "UTC")
		return formatter
	}()

	private static let dayLabelFormatter = RelativeDayLabelFormatter()
}

extension HomeViewModel: CurrencySelectionDelegate {
	func didSelectCurrency(_ currency: Currency.Response.CurrencyItem) {
		selectedCurrency = currency
		withAnimation(.easeInOut(duration: 0.25)) {
			isCurrencyDialogPresented = false
		}
	}
}

/// "Today" / "Yesterday" / short date — mirrors `RecordsViewModel`'s day-section labeling so
/// Home's recent-transaction rows read the same way Records' do.
private struct RelativeDayLabelFormatter {
	private let shortDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMM d"
		return formatter
	}()

	func string(for date: Date) -> String {
		let calendar = Calendar.current
		if calendar.isDateInToday(date) { return "Today" }
		if calendar.isDateInYesterday(date) { return "Yesterday" }
		return shortDateFormatter.string(from: date)
	}
}
