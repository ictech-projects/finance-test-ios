//
//  Transaction.swift
//  finance-test-ios
//

import Foundation

enum TransactionRecord {
	enum Request {}
	enum Response {}
}

extension TransactionRecord.Request {

	struct GetTransactions: Codable, Equatable {
		let since: String?
	}
}

extension TransactionRecord.Response {

	struct TransactionItem: Codable, Equatable, Hashable {
		let id: String?
		let userId: String?
		let accountId: String?
		let categoryId: String?
		let currencyId: String?
		let exchangeRateToAnchor: String?
		let type: String?
		let amount: String?
		let description: String?
		let transactionDate: String?
		let createdAt: String?
		let updatedAt: String?
		let deletedAt: String?

		enum CodingKeys: String, CodingKey {
			case id
			case userId = "user_id"
			case accountId = "account_id"
			case categoryId = "category_id"
			case currencyId = "currency_id"
			case exchangeRateToAnchor = "exchange_rate_to_anchor"
			case type, amount, description
			case transactionDate = "transaction_date"
			case createdAt = "created_at"
			case updatedAt = "updated_at"
			case deletedAt = "deleted_at"
		}
	}

	struct TransactionList: Codable, Equatable, Hashable {
		let items: [TransactionItem]?
		let serverTime: String?

		enum CodingKeys: String, CodingKey {
			case items
			case serverTime = "server_time"
		}
	}
}

extension TransactionRecord.Response.TransactionItem {
	static let lunch = TransactionRecord.Response.TransactionItem(
		id: "01K3TX0000000000000000TX01", userId: "01K3US0000000000000000US01",
		accountId: "01K3AC0000000000000000AC01", categoryId: "01K3CT0000000000000000CT01",
		currencyId: "usd", exchangeRateToAnchor: "1",
		type: "expense", amount: "42.50", description: "Lunch at the Bistro",
		transactionDate: "2026-07-27", createdAt: "2026-07-27T12:45:00Z", updatedAt: nil, deletedAt: nil
	)

	static let mocks: [TransactionRecord.Response.TransactionItem] = [
		.lunch,
		TransactionRecord.Response.TransactionItem(
			id: "01K3TX0000000000000000TX02", userId: "01K3US0000000000000000US01",
			accountId: "01K3AC0000000000000000AC02", categoryId: "01K3CT0000000000000000CT02",
			currencyId: "usd", exchangeRateToAnchor: "1",
			type: "income", amount: "1200.00", description: "UI Design Project",
			transactionDate: "2026-07-27", createdAt: "2026-07-27T09:15:00Z", updatedAt: nil, deletedAt: nil
		),
		TransactionRecord.Response.TransactionItem(
			id: "01K3TX0000000000000000TX03", userId: "01K3US0000000000000000US01",
			accountId: "01K3AC0000000000000000AC03", categoryId: "01K3CT0000000000000000CT03",
			currencyId: "usd", exchangeRateToAnchor: "1",
			type: "expense", amount: "65.00", description: "Fuel Refill",
			transactionDate: "2026-07-26", createdAt: "2026-07-26T18:20:00Z", updatedAt: nil, deletedAt: nil
		),
		TransactionRecord.Response.TransactionItem(
			id: "01K3TX0000000000000000TX04", userId: "01K3US0000000000000000US01",
			accountId: "01K3AC0000000000000000AC02", categoryId: "01K3CT0000000000000000CT04",
			currencyId: "usd", exchangeRateToAnchor: "1",
			type: "expense", amount: "128.45", description: "Weekly Supplies",
			transactionDate: "2026-07-26", createdAt: "2026-07-26T11:00:00Z", updatedAt: nil, deletedAt: nil
		),
		TransactionRecord.Response.TransactionItem(
			id: "01K3TX0000000000000000TX05", userId: "01K3US0000000000000000US01",
			accountId: "01K3AC0000000000000000AC03", categoryId: "01K3CT0000000000000000CT05",
			currencyId: "usd", exchangeRateToAnchor: "1",
			type: "expense", amount: "15.99", description: "Streaming Service",
			transactionDate: "2026-07-24", createdAt: "2026-07-24T15:30:00Z", updatedAt: nil, deletedAt: nil
		)
	]
}
