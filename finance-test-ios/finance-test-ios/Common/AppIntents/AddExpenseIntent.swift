//
//  AddExpenseIntent.swift
//  finance-test-ios
//

import AppIntents
import SwiftUI

struct AddExpenseIntent: AppIntent {
	static var title: LocalizedStringResource = "Log an Expense"
	static var description = IntentDescription("Add a new expense transaction without opening the app.")

	@Parameter(title: "Amount")
	var amount: Double

	@Parameter(title: "Merchant or Note")
	var merchant: String?

	/// Required on purpose: there is no backend notion of a "default" category (unlike accounts,
	/// which carry `isDefault`), so picking one on the user's behalf silently mis-files the
	/// expense. Being required makes App Intents prompt with the user's categories to choose
	/// from, using `TransactionCategoryEntityQuery.suggestedEntities()`.
	@Parameter(title: "Category")
	var category: TransactionCategoryEntity

	@Parameter(title: "Account")
	var account: AccountEntity?

	static var parameterSummary: some ParameterSummary {
		Summary("Log a \(\.$amount) expense") {
			\.$merchant
			\.$category
			\.$account
		}
	}

	func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
		let result = try await AddExpenseIntentHandler().addExpense(
			amount: amount,
			merchant: merchant,
			accountId: account?.id,
			categoryId: category.id
		)
		// The dialog is the spoken confirmation; the snippet shows the record it created. Keeping
		// them complementary rather than duplicated is Apple's guidance for result views.
		return .result(
			dialog: "Logged your \(result.categoryName) expense of \(result.amount.currencyFormatted())."
		) {
			AddExpenseSnippetView(result: result)
				.padding()
		}
	}
}
