//
//  ReportsViewModelTests.swift
//  finance-test-iosTests
//

import Combine
import Foundation
import SwiftUI
import Testing
@testable import finance_test_ios

@Suite("ReportsViewModel")
@MainActor
final class ReportsViewModelTests: MemoryLeakTrackingSuite {

	// MARK: - onLoad

	@Test
	func onLoad_success_setsSummaryAndLoadedState() async {
		let referenceDate = anyReferenceDate()
		let summary = anyPeriodSummary(
			periodLabel: "July 2026", totalIncome: 500, totalSpent: 100, netSaved: 400, savingsRatePercent: 80,
			categoryBreakdown: [anyCategoryBreakdown()], topExpenses: [anyExpense()]
		)
		let repository = ReportsMockRepository(result: .loaded(anyPeriodSummarySuccessResponse(data: summary)))
		let sut = makeSUT(reportsRepository: repository, referenceDate: referenceDate)
		var receivedStates = [ReportsViewModel.ViewState]()

		await confirmation("viewState emits .loaded") { confirm in
			let cancellable = sut.$viewState
				.dropFirst(2)
				.sink { state in
					receivedStates.append(state)
					confirm()
				}

			await sut.onLoad()

			cancellable.cancel()
		}

		#expect(repository.invocations == [.getPeriodSummary(anyGetPeriodSummaryRequest(referenceDate: referenceDate))])
		#expect(receivedStates == [.loaded])
		#expect(sut.summary.periodLabel == "July 2026")
		#expect(sut.summary.netSaved == 400)
		#expect(sut.summary.savingsRatePercent == 80)
		#expect(sut.summary.totalSpent == 100)
		#expect(sut.summary.categories.count == 1)
		#expect(sut.summary.topExpenses.count == 1)
		#expect(sut.isRefreshing == false)
	}

	@Test
	func onLoad_whenRepositoryErrors_setsErrorState() async {
		let anyError = NSError(domain: "", code: -1)
		let repository = ReportsMockRepository(result: .error(anyError))
		let sut = makeSUT(reportsRepository: repository)
		var receivedStates = [ReportsViewModel.ViewState]()

		await confirmation("viewState emits .error") { confirm in
			let cancellable = sut.$viewState
				.dropFirst(2)
				.sink { state in
					receivedStates.append(state)
					confirm()
				}

			await sut.onLoad()

			cancellable.cancel()
		}

		#expect(receivedStates == [.error])
		#expect(sut.isRefreshing == false)
	}

	@Test
	func onLoad_whenResponseDataIsNil_setsErrorState() async {
		let repository = ReportsMockRepository(
			result: .loaded(GeneralResponse(success: true, statusCode: 200, message: "Empty", data: nil))
		)
		let sut = makeSUT(reportsRepository: repository)
		var receivedStates = [ReportsViewModel.ViewState]()

		await confirmation("viewState emits .error") { confirm in
			let cancellable = sut.$viewState
				.dropFirst(2)
				.sink { state in
					receivedStates.append(state)
					confirm()
				}

			await sut.onLoad()

			cancellable.cancel()
		}

		#expect(receivedStates == [.error])
		#expect(sut.isRefreshing == false)
	}

	@Test
	func onLoad_mapsCategoryAndExpenseFallbackValuesWhenFieldsAreMissing() async {
		let category = Reports.Response.CategoryBreakdown(categoryId: nil, name: nil, colorHex: nil, totalAmount: 10, percent: 1.0)
		let expense = Reports.Response.Expense(
			transactionId: nil, title: nil, subtitle: nil, amount: 10, categoryIcon: nil, categoryColorHex: nil
		)
		let summary = anyPeriodSummary(categoryBreakdown: [category], topExpenses: [expense])
		let repository = ReportsMockRepository(result: .loaded(anyPeriodSummarySuccessResponse(data: summary)))
		let sut = makeSUT(reportsRepository: repository)

		await sut.onLoad()

		#expect(sut.summary.categories.first?.name == "Uncategorized")
		#expect(sut.summary.categories.first?.color == .recordsCardBorder)
		#expect(sut.summary.topExpenses.first?.title == "Expense")
		#expect(sut.summary.topExpenses.first?.subtitle == "")
		#expect(sut.summary.topExpenses.first?.iconSystemName == "creditcard")
		#expect(sut.summary.topExpenses.first?.iconBackground == .recordsCardBorder)
		#expect(sut.summary.topExpenses.first?.iconForeground == .white)
	}

	@Test(arguments: [0, 1, 2])
	func onLoad_withVaryingCategoryCounts_producesMatchingCategoryCount(count: Int) async {
		let categories = (0..<count).map { anyCategoryBreakdown(categoryId: "c\($0)") }
		let summary = anyPeriodSummary(categoryBreakdown: categories)
		let repository = ReportsMockRepository(result: .loaded(anyPeriodSummarySuccessResponse(data: summary)))
		let sut = makeSUT(reportsRepository: repository)

		await sut.onLoad()

		#expect(sut.summary.categories.count == count)
	}

	@Test(arguments: [0, 1, 2])
	func onLoad_withVaryingTopExpenseCounts_producesMatchingExpenseCount(count: Int) async {
		let expenses = (0..<count).map { anyExpense(transactionId: "e\($0)") }
		let summary = anyPeriodSummary(topExpenses: expenses)
		let repository = ReportsMockRepository(result: .loaded(anyPeriodSummarySuccessResponse(data: summary)))
		let sut = makeSUT(reportsRepository: repository)

		await sut.onLoad()

		#expect(sut.summary.topExpenses.count == count)
	}

	// MARK: - selectPeriodType

	@Test
	func selectPeriodType_sameType_doesNothing() {
		let referenceDate = anyReferenceDate()
		let sut = makeSUT(referenceDate: referenceDate)

		sut.selectPeriodType(.monthly)

		#expect(sut.periodType == .monthly)
		#expect(sut.referenceDate == referenceDate)
	}

	@Test
	func selectPeriodType_differentType_updatesPeriodTypeAndResetsReferenceDateToToday() async {
		let sut = makeSUT(referenceDate: anyReferenceDate())
		let beforeCall = Date()

		sut.selectPeriodType(.yearly)

		#expect(sut.periodType == .yearly)
		#expect(sut.referenceDate >= beforeCall)
		await drainPendingTasks()
	}

	@Test
	func onLoad_afterSelectingYearlyPeriodType_sendsYearlyRequest() async {
		let repository = ReportsMockRepository(result: .loaded(anyPeriodSummarySuccessResponse()))
		let sut = makeSUT(reportsRepository: repository)
		sut.selectPeriodType(.yearly)

		await sut.onLoad()

		#expect(repository.invocations.last == .getPeriodSummary(
			Reports.Request.GetPeriodSummary(periodType: .yearly, referenceDate: sut.referenceDate)
		))
		await drainPendingTasks()
	}

	// MARK: - goToPreviousPeriod / goToNextPeriod

	@Test
	func goToPreviousPeriod_movesReferenceDateBackOneMonth() async {
		let sut = makeSUT(referenceDate: anyReferenceDate())
		let before = sut.referenceDate

		sut.goToPreviousPeriod()

		let expected = Calendar.current.date(byAdding: .month, value: -1, to: before)
		#expect(sut.referenceDate == expected)
		await drainPendingTasks()
	}

	@Test
	func canGoToNextPeriod_forPastPeriod_returnsTrue() {
		let sut = makeSUT(referenceDate: anyReferenceDate())
		#expect(sut.canGoToNextPeriod == true)
	}

	@Test
	func canGoToNextPeriod_forCurrentPeriod_returnsFalse() {
		let sut = makeSUT(referenceDate: Date())
		#expect(sut.canGoToNextPeriod == false)
	}

	@Test
	func goToNextPeriod_whenCanGoToNextPeriod_movesReferenceDateForwardOneMonth() async {
		let sut = makeSUT(referenceDate: anyReferenceDate())
		let before = sut.referenceDate

		sut.goToNextPeriod()

		let expected = Calendar.current.date(byAdding: .month, value: 1, to: before)
		#expect(sut.referenceDate == expected)
		await drainPendingTasks()
	}

	@Test
	func goToNextPeriod_whenAtCurrentPeriod_doesNothing() {
		let now = Date()
		let sut = makeSUT(referenceDate: now)

		sut.goToNextPeriod()

		#expect(sut.referenceDate == now)
	}

	@Test
	func canGoToPreviousPeriod_alwaysReturnsTrue() {
		let sut = makeSUT()
		#expect(sut.canGoToPreviousPeriod == true)
	}

	// MARK: - selectPeriod

	@Test
	func selectPeriod_futureDate_clampsToToday() async {
		let sut = makeSUT()
		let future = Date().addingTimeInterval(60 * 60 * 24 * 365)

		sut.selectPeriod(referenceDate: future)

		#expect(sut.referenceDate < future)
		#expect(sut.referenceDate <= Date())
		await drainPendingTasks()
	}

	@Test
	func selectPeriod_pastDate_setsReferenceDateExactly() async {
		let sut = makeSUT()
		let past = Date().addingTimeInterval(-60 * 60 * 24 * 365)

		sut.selectPeriod(referenceDate: past)

		#expect(sut.referenceDate == past)
		await drainPendingTasks()
	}

	// MARK: - presentPeriodPicker

	@Test
	func presentPeriodPicker_setsIsPeriodPickerPresentedTrue() {
		let sut = makeSUT()
		#expect(sut.isPeriodPickerPresented == false)

		sut.presentPeriodPicker()

		#expect(sut.isPeriodPickerPresented == true)
	}

	// MARK: - Helpers

	/// `selectPeriodType`/`goToPreviousPeriod`/`goToNextPeriod`/`selectPeriod` fire an unstructured
	/// `Task { await load() }` that captures `self` without awaiting it. Yielding repeatedly lets
	/// that task actually run and release its capture before `trackForMemoryLeak` checks `sut`,
	/// avoiding a false-positive leak report for a task that would have finished anyway.
	private func drainPendingTasks() async {
		for _ in 0..<10 {
			await Task.yield()
		}
	}

	private func makeSUT(
		reportsRepository: ReportsMockRepository = ReportsMockRepository(),
		referenceDate: Date = anyReferenceDate(),
		file: StaticString = #filePath,
		line: UInt = #line
	) -> ReportsViewModel {
		let sut = ReportsViewModel(reportsRepository: reportsRepository, referenceDate: referenceDate)
		trackForMemoryLeak(sut, file: file, line: line)
		return sut
	}
}
