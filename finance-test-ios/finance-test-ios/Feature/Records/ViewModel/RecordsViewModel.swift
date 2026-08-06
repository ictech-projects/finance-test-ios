//
//  RecordsViewModel.swift
//  finance-test-ios
//

import Combine
import Foundation

@MainActor
final class RecordsViewModel: ObservableObject {
	enum ViewState: Equatable { case initial, loading, loaded, error }

	private struct Entry {
		let display: RecordsRowDisplay
		let categoryName: String
		let accountName: String
		let dayKey: Date
		let timestamp: Date
	}

	@Published private(set) var viewState = ViewState.initial
	@Published private(set) var sections: [RecordsSection] = []
	@Published var typeFilter = RecordsTypeFilter.all {
		didSet { rebuildSections() }
	}
	@Published var categoryFilter: String? {
		didSet { rebuildSections() }
	}
	@Published var accountFilter: String? {
		didSet { rebuildSections() }
	}
	@Published var isAddTransactionPresented = false

	private(set) var availableCategoryNames: [String] = []
	private(set) var availableAccountNames: [String] = []

	private let transactionRepository: any TransactionRepository
	private var entries: [Entry] = []

	init(transactionRepository: some TransactionRepository = TransactionMockRepository()) {
		self.transactionRepository = transactionRepository
	}

	func presentAddTransaction() {
		isAddTransactionPresented = true
	}

	func onLoad() async {
		viewState = .loading

		do {
			let state = try await transactionRepository.getTransactions(request: .init(since: nil))
			switch state {
			case .loaded(let response):
				entries = (response.data?.items ?? []).compactMap(Self.makeEntry)
				availableCategoryNames = Set(entries.map(\.categoryName)).sorted()
				availableAccountNames = Set(entries.map(\.accountName)).sorted()
				rebuildSections()
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

	// MARK: - Grouping & Filtering

	private func rebuildSections() {
		let filtered = entries.filter { entry in
			switch typeFilter {
			case .all: break
			case .income: guard entry.display.isCredit else { return false }
			case .expense: guard !entry.display.isCredit else { return false }
			}
			if let categoryFilter, entry.categoryName != categoryFilter { return false }
			if let accountFilter, entry.accountName != accountFilter { return false }
			return true
		}

		let grouped = Dictionary(grouping: filtered, by: \.dayKey)
		let calendar = Calendar.current

		sections = grouped.keys.sorted(by: >).map { dayKey in
			let items = grouped[dayKey, default: []]
				.sorted { $0.timestamp > $1.timestamp }
				.map(\.display)

			let title: String
			let subtitle: String
			if calendar.isDateInToday(dayKey) {
				title = "Today"
				subtitle = Self.mediumDateFormatter.string(from: dayKey)
			} else if calendar.isDateInYesterday(dayKey) {
				title = "Yesterday"
				subtitle = Self.mediumDateFormatter.string(from: dayKey)
			} else {
				title = Self.shortDateFormatter.string(from: dayKey)
				subtitle = Self.weekdayFormatter.string(from: dayKey)
			}

			return RecordsSection(id: Self.dayKeyFormatter.string(from: dayKey), title: title, subtitle: subtitle, items: items)
		}
	}

	private static func makeEntry(from item: TransactionRecord.Response.TransactionItem) -> Entry? {
		guard
			let id = item.id,
			let categoryId = item.categoryId,
			let accountId = item.accountId,
			let amountString = item.amount,
			let amount = Double(amountString),
			let type = item.type,
			let transactionDateString = item.transactionDate,
			let dayKey = dayKeyFormatter.date(from: transactionDateString)
		else { return nil }

		let category = RecordsCatalog.categories[categoryId] ?? RecordsCatalog.unknownCategory
		let account = RecordsCatalog.accounts[accountId] ?? RecordsCatalog.unknownAccount
		let isCredit = type == .income
		let signedAmount = isCredit ? amount : -amount
		let timestamp = item.createdAt.flatMap(timestampFormatter.date(from:)) ?? dayKey

		let display = RecordsRowDisplay(
			id: id,
			categoryName: category.name,
			categoryIcon: category.icon,
			categoryIconTint: category.iconTint,
			categoryIconBackground: category.iconBackground,
			description: item.description ?? "",
			accountName: account.name,
			accountIcon: account.icon,
			amountLabel: signedAmount.currencyFormatted(showsSign: isCredit),
			isCredit: isCredit,
			timeLabel: timeFormatter.string(from: timestamp)
		)

		return Entry(display: display, categoryName: category.name, accountName: account.name, dayKey: dayKey, timestamp: timestamp)
	}

	// MARK: - Formatters

	private static let dayKeyFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(identifier: "UTC")
		return formatter
	}()

	private static let timestampFormatter: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime]
		return formatter
	}()

	private static let timeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "h:mm a"
		return formatter
	}()

	private static let mediumDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMM d, yyyy"
		return formatter
	}()

	private static let shortDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMM d"
		return formatter
	}()

	private static let weekdayFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE"
		return formatter
	}()
}

extension RecordsViewModel: AddTransactionDelegate {
	func didCreateTransaction(_ item: TransactionRecord.Response.TransactionItem) {
		isAddTransactionPresented = false
		Task { await onLoad() }
	}
}
