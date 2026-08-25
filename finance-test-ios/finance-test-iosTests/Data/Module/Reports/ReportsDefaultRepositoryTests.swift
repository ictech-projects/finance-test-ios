//
//  ReportsDefaultRepositoryTests.swift
//  finance-test-iosTests
//

import Foundation
import Testing
@testable import finance_test_ios

@Suite("ReportsDefaultRepository")
struct ReportsDefaultRepositoryTests {

	// MARK: - Tests

	@Test func getPeriodSummary_callsTransactionAndCategoryRepositoriesWithCorrectRequests() async throws {
		let transactionRepository = TransactionMockRepository()
		let categoryRepository = TransactionCategoryMockRepository()
		let sut = makeSUT(transactionRepository: transactionRepository, categoryRepository: categoryRepository)

		_ = try await sut.getPeriodSummary(request: anyGetPeriodSummaryRequest())

		#expect(transactionRepository.invocations == [.getTransactions(anyGetTransactionsRequest())])
		#expect(categoryRepository.invocations == [.getCategories(anyGetCategoriesRequest())])
	}

	@Test func getPeriodSummary_whenTransactionRepositoryErrors_skipsCategoryRepositoryAndReturnsError() async throws {
		let dummyError = NSError(domain: "TestError", code: 999)
		let transactionRepository = TransactionMockRepository(result: .error(dummyError))
		let categoryRepository = TransactionCategoryMockRepository()
		let sut = makeSUT(transactionRepository: transactionRepository, categoryRepository: categoryRepository)

		let result = try await sut.getPeriodSummary(request: anyGetPeriodSummaryRequest())

		guard case .error(let error as NSError) = result else {
			Issue.record("Expected .error(NSError) but got \(result)")
			return
		}
		#expect(error.domain == "TestError")
		#expect(error.code == 999)
		#expect(categoryRepository.invocations.isEmpty)
	}

	@Test(arguments: [401, 404, 500])
	func getPeriodSummary_whenTransactionRepositoryReturnsErrorResponse_propagatesStatusCodeAndMessage(
		statusCode: Int
	) async throws {
		let expectedError = ErrorResponse(success: false, statusCode: statusCode, message: "Request failed", errors: nil)
		let transactionRepository = TransactionMockRepository(result: .error(expectedError))
		let sut = makeSUT(transactionRepository: transactionRepository)

		let result = try await sut.getPeriodSummary(request: anyGetPeriodSummaryRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse) but got \(result)")
			return
		}
		#expect(error.statusCode == statusCode)
		#expect(error.message == "Request failed")
	}

	@Test func getPeriodSummary_whenCategoryRepositoryErrors_returnsError() async throws {
		let expectedError = ErrorResponse(success: false, statusCode: 500, message: "Server error", errors: nil)
		let categoryRepository = TransactionCategoryMockRepository(result: .error(expectedError))
		let sut = makeSUT(categoryRepository: categoryRepository)

		let result = try await sut.getPeriodSummary(request: anyGetPeriodSummaryRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse) but got \(result)")
			return
		}
		#expect(error.statusCode == 500)
		#expect(error.message == "Server error")
	}

	@Test func getPeriodSummary_success_computesTotalsForThePeriod() async throws {
		let expense = anyTransactionItem(id: "e1", type: .expense, amount: "100.00")
		let income = anyTransactionItem(id: "i1", type: .income, amount: "500.00")
		let transactionRepository = TransactionMockRepository(
			result: .loaded(anyTransactionListSuccessResponse(items: [expense, income]))
		)
		let sut = makeSUT(transactionRepository: transactionRepository)

		let result = try await sut.getPeriodSummary(request: anyGetPeriodSummaryRequest(referenceDate: anyReferenceDate()))

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.success == true)
		#expect(response.statusCode == 200)
		#expect(response.data?.periodLabel == "July 2026")
		#expect(response.data?.totalSpent == 100.00)
		#expect(response.data?.totalIncome == 500.00)
		#expect(response.data?.netSaved == 400.00)
		#expect(response.data?.savingsRatePercent == 80)
	}

	@Test func getPeriodSummary_whenNoIncome_savingsRatePercentIsZero() async throws {
		let expense = anyTransactionItem(id: "e1", type: .expense, amount: "50.00")
		let transactionRepository = TransactionMockRepository(
			result: .loaded(anyTransactionListSuccessResponse(items: [expense]))
		)
		let sut = makeSUT(transactionRepository: transactionRepository)

		let result = try await sut.getPeriodSummary(request: anyGetPeriodSummaryRequest())

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.data?.savingsRatePercent == 0)
	}

	@Test func getPeriodSummary_excludesTransactionsOutsideThePeriod() async throws {
		let inPeriod = anyTransactionItem(id: "in", type: .expense, amount: "50.00") // default date is 2026-07-27
		let outOfPeriod = TransactionRecord.Response.TransactionItem(
			id: "out", userId: nil, accountId: nil, categoryId: nil, currencyId: nil, exchangeRateToAnchor: nil,
			type: .expense, amount: "999.00", description: nil, transactionDate: "2026-05-10",
			createdAt: nil, updatedAt: nil, deletedAt: nil
		)
		let transactionRepository = TransactionMockRepository(
			result: .loaded(anyTransactionListSuccessResponse(items: [inPeriod, outOfPeriod]))
		)
		let sut = makeSUT(transactionRepository: transactionRepository)

		let result = try await sut.getPeriodSummary(request: anyGetPeriodSummaryRequest(referenceDate: anyReferenceDate()))

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.data?.totalSpent == 50.00)
	}

	@Test(arguments: [0, 1, 2])
	func getPeriodSummary_withVaryingExpenseCounts_returnsMatchingTopExpensesCount(itemCount: Int) async throws {
		let items = (0..<itemCount).map { anyTransactionItem(id: "e\($0)", type: .expense, amount: "10.00") }
		let transactionRepository = TransactionMockRepository(
			result: .loaded(anyTransactionListSuccessResponse(items: items))
		)
		let sut = makeSUT(transactionRepository: transactionRepository)

		let result = try await sut.getPeriodSummary(request: anyGetPeriodSummaryRequest())

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.data?.topExpenses.count == itemCount)
	}

	@Test func getPeriodSummary_limitsTopExpensesToFiveHighestAmounts() async throws {
		let amounts = ["10.00", "50.00", "20.00", "60.00", "30.00", "5.00"]
		let items = amounts.enumerated().map { index, amount in
			anyTransactionItem(id: "e\(index)", type: .expense, amount: amount)
		}
		let transactionRepository = TransactionMockRepository(
			result: .loaded(anyTransactionListSuccessResponse(items: items))
		)
		let sut = makeSUT(transactionRepository: transactionRepository)

		let result = try await sut.getPeriodSummary(request: anyGetPeriodSummaryRequest())

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.data?.topExpenses.count == 5)
		#expect(response.data?.topExpenses.map(\.amount) == [60, 50, 30, 20, 10])
	}

	@Test func getPeriodSummary_categoryBreakdown_groupsSortsAndComputesPercent() async throws {
		let housing1 = anyTransactionItem(id: "h1", categoryId: "01K3CT0000000000000000CT01", type: .expense, amount: "30.00")
		let housing2 = anyTransactionItem(id: "h2", categoryId: "01K3CT0000000000000000CT01", type: .expense, amount: "30.00")
		let transport = anyTransactionItem(id: "t1", categoryId: "01K3CT0000000000000000CT03", type: .expense, amount: "40.00")
		let housingCategory = anyCategoryItem(id: "01K3CT0000000000000000CT01", name: "Dining & Drinks", type: .expense)
		let transportCategory = anyCategoryItem(id: "01K3CT0000000000000000CT03", name: "Transport", type: .expense)
		let transactionRepository = TransactionMockRepository(
			result: .loaded(anyTransactionListSuccessResponse(items: [housing1, housing2, transport]))
		)
		let categoryRepository = TransactionCategoryMockRepository(
			result: .loaded(anyCategoryListSuccessResponse(items: [housingCategory, transportCategory]))
		)
		let sut = makeSUT(transactionRepository: transactionRepository, categoryRepository: categoryRepository)

		let result = try await sut.getPeriodSummary(request: anyGetPeriodSummaryRequest())

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		let breakdown = response.data?.categoryBreakdown ?? []
		#expect(breakdown.count == 2)
		#expect(breakdown.first?.name == "Dining & Drinks")
		#expect(breakdown.first?.totalAmount == 60)
		#expect(breakdown.first?.percent == 0.6)
		#expect(breakdown.last?.name == "Transport")
		#expect(breakdown.last?.totalAmount == 40)
		#expect(breakdown.last?.percent == 0.4)
	}

	// MARK: - Helpers

	// `ReportsDefaultRepository` is a struct (per the codebase's Repository convention), so
	// there's no reference to leak — `trackForMemoryLeak` doesn't apply here.
	private func makeSUT(
		transactionRepository: TransactionMockRepository = TransactionMockRepository(),
		categoryRepository: TransactionCategoryMockRepository = TransactionCategoryMockRepository()
	) -> ReportsDefaultRepository {
		ReportsDefaultRepository(transactionRepository: transactionRepository, categoryRepository: categoryRepository)
	}
}
