//
//  ReportsViewModel.swift
//  finance-test-ios
//

import Combine
import SwiftUI

@MainActor
final class ReportsViewModel: ObservableObject {
	typealias PeriodType = Reports.PeriodType

	enum ViewState: Equatable { case initial, loading, loaded, error }

	@Published private(set) var periodType = PeriodType.monthly
	@Published private(set) var referenceDate: Date
	@Published private(set) var viewState = ViewState.initial
	@Published private(set) var isRefreshing = false
	@Published private(set) var summary = ReportsPeriodSummary.empty
	@Published var isPeriodPickerPresented = false

	private let reportsRepository: any ReportsRepository
	private let calendar = Calendar.current
	private var loadTask: Task<Void, Never>?

	init(
		reportsRepository: some ReportsRepository = ReportsDefaultRepository(),
		referenceDate: Date = Date()
	) {
		self.reportsRepository = reportsRepository
		self.referenceDate = referenceDate
	}

	var canGoToPreviousPeriod: Bool { true }

	var canGoToNextPeriod: Bool { !isCurrentPeriod(referenceDate) }

	func onLoad() async {
		await load()
	}

	func selectPeriodType(_ type: PeriodType) {
		guard periodType != type else { return }
		periodType = type
		referenceDate = Date()
		reload()
	}

	func goToPreviousPeriod() {
		guard let newDate = calendar.date(byAdding: component, value: -1, to: referenceDate) else { return }
		referenceDate = newDate
		reload()
	}

	func goToNextPeriod() {
		guard canGoToNextPeriod, let newDate = calendar.date(byAdding: component, value: 1, to: referenceDate) else { return }
		referenceDate = newDate
		reload()
	}

	/// Jumps directly to an arbitrary month/year, e.g. from the period picker sheet. Clamped so a
	/// caller can never select a period beyond the current one.
	func selectPeriod(referenceDate date: Date) {
		referenceDate = min(date, Date())
		reload()
	}

	func presentPeriodPicker() {
		isPeriodPickerPresented = true
	}

	private var component: Calendar.Component {
		periodType == .monthly ? .month : .year
	}

	private func isCurrentPeriod(_ date: Date) -> Bool {
		calendar.isDate(date, equalTo: Date(), toGranularity: component)
	}

	private func reload() {
		loadTask?.cancel()
		loadTask = Task { await load() }
	}

	private func load() async {
		// Only the very first load (or a retry after an error) blanks the screen with a spinner —
		// once content is on screen, a period change should update in place, not flash to blank.
		if viewState == .loaded {
			isRefreshing = true
		} else {
			viewState = .loading
		}

		let request = Reports.Request.GetPeriodSummary(periodType: periodType, referenceDate: referenceDate)

		do {
			let state = try await reportsRepository.getPeriodSummary(request: request)
			// A cancelled task lost a race to a newer navigation — its result is stale, and a
			// still-in-flight newer task owns `isRefreshing`/`viewState` from here on.
			guard !Task.isCancelled else { return }

			switch state {
			case .loaded(let response):
				guard let data = response.data else {
					viewState = .error
					isRefreshing = false
					return
				}
				summary = Self.mapSummary(data)
				viewState = .loaded
				isRefreshing = false
			case .error:
				viewState = .error
				isRefreshing = false
			case .idle, .loading, .refresh, .expired, .paginationLoading:
				break
			}
		} catch {
			guard !Task.isCancelled else { return }
			viewState = .error
			isRefreshing = false
		}
	}

	private static func mapSummary(_ data: Reports.Response.PeriodSummary) -> ReportsPeriodSummary {
		ReportsPeriodSummary(
			periodLabel: data.periodLabel,
			periodSubtitle: data.periodSubtitle,
			netSaved: data.netSaved,
			savingsRatePercent: data.savingsRatePercent,
			totalSpent: data.totalSpent,
			categories: data.categoryBreakdown.map(Self.mapCategory),
			topExpenses: data.topExpenses.map(Self.mapExpense)
		)
	}

	private static func mapCategory(_ category: Reports.Response.CategoryBreakdown) -> ReportsCategoryBreakdown {
		ReportsCategoryBreakdown(
			name: category.name ?? "Uncategorized",
			percent: category.percent,
			color: category.colorHex.flatMap { Color(hex: $0) } ?? .recordsCardBorder
		)
	}

	private static func mapExpense(_ expense: Reports.Response.Expense) -> ReportsExpenseItem {
		ReportsExpenseItem(
			title: expense.title ?? "Expense",
			subtitle: expense.subtitle ?? "",
			amount: expense.amount,
			iconSystemName: expense.categoryIcon ?? "creditcard",
			iconBackground: expense.categoryColorHex.flatMap { Color(hex: $0) } ?? .recordsCardBorder,
			iconForeground: .white
		)
	}
}
