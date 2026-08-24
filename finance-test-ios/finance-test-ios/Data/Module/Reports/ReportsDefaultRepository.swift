//
//  ReportsDefaultRepository.swift
//  finance-test-ios
//

import Foundation

/// Computes report summaries locally — there is no `/reports` backend endpoint. Raw data comes
/// from `TransactionRepository` and `TransactionCategoryRepository`; this repository owns the
/// period filtering, sums, and breakdown math on top of it.
struct ReportsDefaultRepository: ReportsRepository {

	private let transactionRepository: any TransactionRepository
	private let categoryRepository: any TransactionCategoryRepository

	init(
		transactionRepository: some TransactionRepository = TransactionDefaultRepository(),
		categoryRepository: some TransactionCategoryRepository = TransactionCategoryDefaultRepository()
	) {
		self.transactionRepository = transactionRepository
		self.categoryRepository = categoryRepository
	}

	func getPeriodSummary(
		request: Reports.Request.GetPeriodSummary
	) async throws -> RequestState<GeneralResponse<Reports.Response.PeriodSummary>> {
		await execute {
			let transactions = try await Self.transactionItems(from: transactionRepository)
			let categories = try await Self.categoryItems(from: categoryRepository)

			return GeneralResponse(
				success: true,
				statusCode: 200,
				message: "Period summary computed.",
				data: Self.summarize(transactions: transactions, categories: categories, request: request)
			)
		}
	}

	private static func transactionItems(
		from repository: any TransactionRepository
	) async throws -> [TransactionRecord.Response.TransactionItem] {
		switch try await repository.getTransactions(request: TransactionRecord.Request.GetTransactions(since: nil)) {
		case .loaded(let response):
			return response.data?.items ?? []
		case .error(let error):
			throw error
		default:
			return []
		}
	}

	private static func categoryItems(
		from repository: any TransactionCategoryRepository
	) async throws -> [TransactionCategory.Response.CategoryItem] {
		switch try await repository.getCategories(request: TransactionCategory.Request.GetCategories(type: nil, since: nil)) {
		case .loaded(let response):
			return response.data?.items ?? []
		case .error(let error):
			throw error
		default:
			return []
		}
	}

	private static func summarize(
		transactions: [TransactionRecord.Response.TransactionItem],
		categories: [TransactionCategory.Response.CategoryItem],
		request: Reports.Request.GetPeriodSummary
	) -> Reports.Response.PeriodSummary {
		let bounds = ReportsPeriodFormatting.bounds(for: request.periodType, referenceDate: request.referenceDate)

		let periodTransactions = transactions.filter { item in
			guard let date = item.transactionDate.flatMap(Self.transactionDateFormatter.date(from:)) else { return false }
			return bounds.contains(date)
		}

		let expenses = periodTransactions.filter { $0.type == .expense }
		let income = periodTransactions.filter { $0.type == .income }

		let totalSpent = expenses.reduce(0) { $0 + (Double($1.amount ?? "") ?? 0) }
		let totalIncome = income.reduce(0) { $0 + (Double($1.amount ?? "") ?? 0) }
		let netSaved = totalIncome - totalSpent
		let savingsRatePercent = totalIncome > 0 ? Int((netSaved / totalIncome * 100).rounded()) : 0

		let categoriesById = Dictionary(uniqueKeysWithValues: categories.compactMap { category in
			category.id.map { ($0, category) }
		})

		return Reports.Response.PeriodSummary(
			periodLabel: ReportsPeriodFormatting.label(for: request.periodType, periodStart: bounds.start),
			periodSubtitle: ReportsPeriodFormatting.subtitle(for: request.periodType, bounds: bounds),
			totalIncome: totalIncome,
			totalSpent: totalSpent,
			netSaved: netSaved,
			savingsRatePercent: savingsRatePercent,
			categoryBreakdown: Self.categoryBreakdown(expenses: expenses, categoriesById: categoriesById, totalSpent: totalSpent),
			topExpenses: Self.topExpenses(from: expenses, categoriesById: categoriesById)
		)
	}

	private static func categoryBreakdown(
		expenses: [TransactionRecord.Response.TransactionItem],
		categoriesById: [String: TransactionCategory.Response.CategoryItem],
		totalSpent: Double
	) -> [Reports.Response.CategoryBreakdown] {
		Dictionary(grouping: expenses) { $0.categoryId ?? "" }
			.map { categoryId, items in
				let amount = items.reduce(0) { $0 + (Double($1.amount ?? "") ?? 0) }
				let category = categoriesById[categoryId]

				return Reports.Response.CategoryBreakdown(
					categoryId: categoryId.isEmpty ? nil : categoryId,
					name: category?.name,
					colorHex: category?.color,
					totalAmount: amount,
					percent: totalSpent > 0 ? amount / totalSpent : 0
				)
			}
			.sorted { $0.totalAmount > $1.totalAmount }
	}

	private static func topExpenses(
		from expenses: [TransactionRecord.Response.TransactionItem],
		categoriesById: [String: TransactionCategory.Response.CategoryItem],
		limit: Int = 5
	) -> [Reports.Response.Expense] {
		expenses
			.sorted { (Double($0.amount ?? "") ?? 0) > (Double($1.amount ?? "") ?? 0) }
			.prefix(limit)
			.map { item in
				let category = item.categoryId.flatMap { categoriesById[$0] }

				return Reports.Response.Expense(
					transactionId: item.id,
					title: item.description ?? category?.name,
					subtitle: Self.expenseSubtitle(categoryName: category?.name, transactionDate: item.transactionDate),
					amount: Double(item.amount ?? "") ?? 0,
					categoryIcon: category?.icon,
					categoryColorHex: category?.color
				)
			}
	}

	private static func expenseSubtitle(categoryName: String?, transactionDate: String?) -> String? {
		let day = transactionDate.flatMap(Self.transactionDateFormatter.date(from:)).map(Self.shortDateFormatter.string(from:))

		switch (categoryName, day) {
		case (let name?, let day?): return "\(name) • \(day)"
		case (let name?, nil): return name
		case (nil, let day?): return day
		case (nil, nil): return nil
		}
	}

	private static let transactionDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.calendar = Calendar(identifier: .gregorian)
		formatter.timeZone = TimeZone(identifier: "UTC")
		return formatter
	}()

	private static let shortDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMM d"
		return formatter
	}()
}
