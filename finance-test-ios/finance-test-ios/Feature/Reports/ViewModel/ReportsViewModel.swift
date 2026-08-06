//
//  ReportsViewModel.swift
//  finance-test-ios
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class ReportsViewModel: ObservableObject {
	enum ViewState: Equatable { case initial, loading, loaded, error }

	@Published private(set) var viewState = ViewState.initial
	@Published private(set) var periodMode = ReportsPeriodMode.monthly
	@Published private(set) var periodDate = Date()
	@Published private(set) var summary = ReportsSummary.empty
	@Published private(set) var topExpenses: [ReportsTopExpenseDisplay] = []

	private static let topExpensesLimit = 5

	private let transactionRepository: any TransactionRepository
	private let categoryRepository: any TransactionCategoryRepository
	private var transactions: [TransactionRecord.Response.TransactionItem] = []
	private var categories: [TransactionCategory.Response.CategoryItem] = []

	init(
		transactionRepository: some TransactionRepository = TransactionMockRepository(),
		categoryRepository: some TransactionCategoryRepository = TransactionCategoryMockRepository()
	) {
		self.transactionRepository = transactionRepository
		self.categoryRepository = categoryRepository
	}

	var savingsRate: Double {
		guard summary.totalIncome > 0 else { return 0 }
		return summary.netAmount / summary.totalIncome * 100
	}

	var netSavedLabel: String { summary.netAmount.currencyFormatted(showsSign: true) }
	var netSavedColor: Color { summary.netAmount >= 0 ? .successMain : .dangerMain }

	var savingsRateLabel: String { "\(Int(savingsRate.rounded()))%" }
	var savingsRateColor: Color { savingsRate >= 0 ? .successMain : .dangerMain }
	var savingsRateTrendIcon: String { savingsRate >= 0 ? "arrow.up.right" : "arrow.down.right" }

	var spendingCategories: [SpendingCategory] {
		summary.expenseBreakdown.map { breakdown in
			SpendingCategory(
				name: breakdown.categoryName,
				percent: breakdown.percentage / 100,
				color: breakdown.colorHex.flatMap { Color(hex: $0) } ?? .recordsNeutralIconTint
			)
		}
	}

	var periodTitle: String {
		switch periodMode {
		case .monthly: Self.monthTitleFormatter.string(from: periodDate)
		case .yearly: Self.yearTitleFormatter.string(from: periodDate)
		}
	}

	var periodSubtitle: String {
		let calendar = Calendar.current
		let now = Date()

		switch periodMode {
		case .monthly:
			guard let endOfMonth = calendar.dateInterval(of: .month, for: periodDate)?.end else { return "" }
			let days = calendar.dateComponents([.day], from: now, to: endOfMonth).day ?? 0
			let weeks = max(0, Int((Double(days) / 7).rounded(.up)))
			return "\(weeks) week\(weeks == 1 ? "" : "s") remaining"
		case .yearly:
			guard let endOfYear = calendar.dateInterval(of: .year, for: periodDate)?.end else { return "" }
			let months = calendar.dateComponents([.month], from: now, to: endOfYear).month ?? 0
			let remaining = max(0, months)
			return "\(remaining) month\(remaining == 1 ? "" : "s") remaining"
		}
	}

	func onLoad() async {
		viewState = .loading

		async let transactionsState = transactionRepository.getTransactions(request: .init(since: nil))
		async let categoriesState = categoryRepository.getCategories(request: .init(type: nil, since: nil))

		do {
			let (loadedTransactions, loadedCategories) = try await (transactionsState, categoriesState)

			guard
				case .loaded(let transactionsResponse) = loadedTransactions,
				case .loaded(let categoriesResponse) = loadedCategories
			else {
				viewState = .error
				return
			}

			transactions = transactionsResponse.data?.items ?? []
			categories = categoriesResponse.data?.items ?? []
			periodDate = mostRecentTransactionDate() ?? Date()
			rebuild()
			viewState = .loaded
		} catch {
			viewState = .error
		}
	}

	func selectPeriodMode(_ newMode: ReportsPeriodMode) {
		guard newMode != periodMode else { return }
		periodMode = newMode
		rebuild()
	}

	func goToPreviousPeriod() {
		shiftPeriod(by: -1)
	}

	func goToNextPeriod() {
		shiftPeriod(by: 1)
	}

	// MARK: - Private

	private func shiftPeriod(by amount: Int) {
		let component: Calendar.Component = periodMode == .monthly ? .month : .year
		guard let newDate = Calendar.current.date(byAdding: component, value: amount, to: periodDate) else { return }
		periodDate = newDate
		rebuild()
	}

	private func mostRecentTransactionDate() -> Date? {
		transactions
			.compactMap { $0.transactionDate.flatMap(Self.dayKeyFormatter.date(from:)) }
			.max()
	}

	private func rebuild() {
		let calendar = Calendar.current
		let granularity: Calendar.Component = periodMode == .monthly ? .month : .year

		let periodTransactions = transactions.filter { item in
			guard
				let dateString = item.transactionDate,
				let date = Self.dayKeyFormatter.date(from: dateString)
			else { return false }
			return calendar.isDate(date, equalTo: periodDate, toGranularity: granularity)
		}

		summary = ReportsAggregator.summarize(transactions: periodTransactions, categories: categories)

		let categoriesById = Dictionary(
			categories.compactMap { category in category.id.map { ($0, category) } },
			uniquingKeysWith: { first, _ in first }
		)

		topExpenses = periodTransactions
			.compactMap { item -> (item: TransactionRecord.Response.TransactionItem, amount: Double)? in
				guard item.type == .expense, let amount = item.amount.flatMap(Double.init) else { return nil }
				return (item, amount)
			}
			.sorted { $0.amount > $1.amount }
			.prefix(Self.topExpensesLimit)
			.map { entry in Self.makeTopExpenseDisplay(from: entry.item, categoriesById: categoriesById) }
	}

	private static func makeTopExpenseDisplay(
		from item: TransactionRecord.Response.TransactionItem,
		categoriesById: [String: TransactionCategory.Response.CategoryItem]
	) -> ReportsTopExpenseDisplay {
		let category = item.categoryId.flatMap { categoriesById[$0] }
		let amount = item.amount.flatMap(Double.init) ?? 0
		let date = item.transactionDate.flatMap(dayKeyFormatter.date(from:))
		let tint = category?.color.flatMap { Color(hex: $0) } ?? .recordsNeutralIconTint

		return ReportsTopExpenseDisplay(
			id: item.id ?? UUID().uuidString,
			description: item.description ?? category?.name ?? "Uncategorized",
			categoryName: category?.name ?? "Uncategorized",
			dateLabel: date.map { topExpenseDateFormatter.string(from: $0) } ?? "",
			amountLabel: "-\(amount.currencyFormatted())",
			icon: category?.icon ?? "questionmark.circle",
			iconTint: tint,
			iconBackground: tint.opacity(0.15)
		)
	}

	// MARK: - Formatters

	private static let dayKeyFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(identifier: "UTC")
		return formatter
	}()

	private static let topExpenseDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMM d"
		return formatter
	}()

	private static let monthTitleFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMMM yyyy"
		return formatter
	}()

	private static let yearTitleFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy"
		return formatter
	}()
}
