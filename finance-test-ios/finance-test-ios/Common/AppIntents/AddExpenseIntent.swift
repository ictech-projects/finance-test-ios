//
//  AddExpenseIntent.swift
//  finance-test-ios
//

import AppIntents

struct AddExpenseIntent: AppIntent {
	static var title: LocalizedStringResource = "Log an Expense"
	static var description = IntentDescription("Add a new expense transaction without opening the app.")

	@Parameter(title: "Amount")
	var amount: Double

	@Parameter(title: "Merchant or Note")
	var merchant: String?

	@Parameter(title: "Category")
	var category: TransactionCategoryEntity?

	@Parameter(title: "Account")
	var account: AccountEntity?

	static var parameterSummary: some ParameterSummary {
		Summary("Log a \(\.$amount) expense") {
			\.$merchant
			\.$category
			\.$account
		}
	}

	func perform() async throws -> some IntentResult & ProvidesDialog {
		let result = try await AddExpenseIntentHandler().addExpense(
			amount: amount,
			merchant: merchant,
			accountId: account?.id,
			categoryId: category?.id
		)
		return .result(dialog: "Logged your \(result.categoryName) expense of $\(String(format: "%.2f", result.amount)).")
	}
}
