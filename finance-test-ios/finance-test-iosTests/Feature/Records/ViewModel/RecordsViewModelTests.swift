//
//  RecordsViewModelTests.swift
//  finance-test-iosTests
//

import Combine
import Foundation
import Testing
@testable import finance_test_ios

@Suite("RecordsViewModel")
@MainActor
final class RecordsViewModelTests: MemoryLeakTrackingSuite {

	// MARK: - Tests

	@Test
	func onLoad_success_groupsByDayAndSetsLoadedState() async {
		let today = anyTransactionItem(
			id: "t1", accountId: "01K3AC0000000000000000AC01", categoryId: "01K3CT0000000000000000CT01",
			type: .expense, amount: "10.00"
		)
		let repository = TransactionMockRepository(
			result: .loaded(anyTransactionListSuccessResponse(items: [today]))
		)
		let sut = makeSUT(transactionRepository: repository)
		var receivedStates = [RecordsViewModel.ViewState]()

		await confirmation("viewState emits .loaded") { confirmState in
			let stateCancellable = sut.$viewState
				.dropFirst(2)
				.sink { state in
					receivedStates.append(state)
					confirmState()
				}

			await sut.onLoad()

			stateCancellable.cancel()
		}

		#expect(repository.invocations == [.getTransactions(anyGetTransactionsRequest())])
		#expect(receivedStates == [.loaded])
		#expect(sut.sections.count == 1)
		#expect(sut.sections.first?.items.count == 1)
		#expect(sut.sections.first?.items.first?.amountLabel == (-10.0).currencyFormatted(showsSign: false))
	}

	@Test
	func onLoad_whenError_setsErrorStateAndEmptySections() async {
		let anyError = NSError(domain: "", code: -1)
		let repository = TransactionMockRepository(result: .error(anyError))
		let sut = makeSUT(transactionRepository: repository)
		var receivedStates = [RecordsViewModel.ViewState]()

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
		#expect(sut.sections.isEmpty)
	}

	@Test(arguments: [0, 1, 2])
	func onLoad_withVaryingItemCounts_producesMatchingRowCount(itemCount: Int) async {
		let items = (0..<itemCount).map { index in
			anyTransactionItem(
				id: "t\(index)", accountId: "01K3AC0000000000000000AC01",
				categoryId: "01K3CT0000000000000000CT01", type: .expense, amount: "5.00"
			)
		}
		let repository = TransactionMockRepository(
			result: .loaded(anyTransactionListSuccessResponse(items: items))
		)
		let sut = makeSUT(transactionRepository: repository)

		await sut.onLoad()

		let totalRows = sut.sections.reduce(0) { $0 + $1.items.count }
		#expect(totalRows == itemCount)
	}

	@Test
	func typeFilter_expense_hidesIncomeRows() async {
		let expense = anyTransactionItem(
			id: "expense", accountId: "01K3AC0000000000000000AC01",
			categoryId: "01K3CT0000000000000000CT01", type: .expense, amount: "10.00"
		)
		let income = anyTransactionItem(
			id: "income", accountId: "01K3AC0000000000000000AC02",
			categoryId: "01K3CT0000000000000000CT02", type: .income, amount: "20.00"
		)
		let repository = TransactionMockRepository(
			result: .loaded(anyTransactionListSuccessResponse(items: [expense, income]))
		)
		let sut = makeSUT(transactionRepository: repository)
		await sut.onLoad()

		sut.typeFilter = .expense

		let allIDs = sut.sections.flatMap(\.items).map(\.id)
		#expect(allIDs == ["expense"])
	}

	@Test
	func categoryFilter_specificCategory_onlyShowsMatchingRows() async {
		let dining = anyTransactionItem(
			id: "dining", accountId: "01K3AC0000000000000000AC01",
			categoryId: "01K3CT0000000000000000CT01", type: .expense, amount: "10.00"
		)
		let transport = anyTransactionItem(
			id: "transport", accountId: "01K3AC0000000000000000AC03",
			categoryId: "01K3CT0000000000000000CT03", type: .expense, amount: "20.00"
		)
		let repository = TransactionMockRepository(
			result: .loaded(anyTransactionListSuccessResponse(items: [dining, transport]))
		)
		let sut = makeSUT(transactionRepository: repository)
		await sut.onLoad()

		sut.categoryFilter = "Transport"

		let allIDs = sut.sections.flatMap(\.items).map(\.id)
		#expect(allIDs == ["transport"])
	}

	// MARK: - Helpers

	private func makeSUT(
		transactionRepository: TransactionMockRepository = TransactionMockRepository(),
		file: StaticString = #filePath,
		line: UInt = #line
	) -> RecordsViewModel {
		let sut = RecordsViewModel(transactionRepository: transactionRepository)
		trackForMemoryLeak(sut, file: file, line: line)
		return sut
	}
}
