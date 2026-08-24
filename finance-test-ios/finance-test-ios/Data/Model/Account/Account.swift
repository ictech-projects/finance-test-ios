//
//  Account.swift
//  finance-test-ios
//

import Foundation

enum Account {
	enum Request {}
	enum Response {}
}

extension Account.Request {

	struct GetAccounts: Codable, Equatable {
		let since: String?
	}

	struct CreateAccount: Codable, Equatable {
		let userCurrencyId: String
		let name: String
		let type: String
		let notes: String?
		let color: String?
		let initialBalance: String?
		let isDefault: Bool?

		enum CodingKeys: String, CodingKey {
			case userCurrencyId = "user_currency_id"
			case name, type, notes, color
			case initialBalance = "initial_balance"
			case isDefault = "is_default"
		}
	}

	/// Same wire shape as `CreateAccount` — there's no `PATCH /accounts/{id}`, so an update is
	/// submitted as an `account`/`update` change via `/sync/push` instead (see
	/// `AccountDefaultRepository.updateAccount`). Kept as its own type so call sites read as
	/// "update", matching this codebase's request-naming convention.
	struct UpdateAccount: Codable, Equatable {
		let userCurrencyId: String
		let name: String
		let type: String
		let notes: String?
		let color: String?
		let initialBalance: String?
		let isDefault: Bool?

		enum CodingKeys: String, CodingKey {
			case userCurrencyId = "user_currency_id"
			case name, type, notes, color
			case initialBalance = "initial_balance"
			case isDefault = "is_default"
		}
	}
}

extension Account.Response {

	struct AccountItem: Codable, Equatable, Hashable {
		let id: String?
		let userId: String?
		let userCurrencyId: String?
		let name: String?
		let notes: String?
		let type: String?
		let color: String?
		let initialBalance: String?
		/// Derived (attached by the backend's AccountService); absent on write/sync responses.
		let balance: String?
		let isDefault: Bool?
		let createdAt: String?
		let updatedAt: String?
		let deletedAt: String?

		enum CodingKeys: String, CodingKey {
			case id
			case userId = "user_id"
			case userCurrencyId = "user_currency_id"
			case name, notes, type, color
			case initialBalance = "initial_balance"
			case balance
			case isDefault = "is_default"
			case createdAt = "created_at"
			case updatedAt = "updated_at"
			case deletedAt = "deleted_at"
		}
	}

	struct AccountList: Codable, Equatable, Hashable {
		let items: [AccountItem]?
		let serverTime: String?

		enum CodingKeys: String, CodingKey {
			case items
			case serverTime = "server_time"
		}
	}
}

extension Account.Response.AccountItem {
	/// Shared ids let Add Transaction's picker and Records' display stay visually consistent
	/// while both are mock-backed.
	static let mocks: [Account.Response.AccountItem] = [
		Account.Response.AccountItem(
			id: "01K3AC0000000000000000AC01", userId: "01K3US0000000000000000US01",
			userCurrencyId: "01K3UC0000000000000000UC01", name: "Cash", notes: nil,
			type: "cash", color: "#22C55E", initialBalance: "320", balance: "320",
			isDefault: true, createdAt: nil, updatedAt: nil, deletedAt: nil
		),
		Account.Response.AccountItem(
			id: "01K3AC0000000000000000AC02", userId: "01K3US0000000000000000US01",
			userCurrencyId: "01K3UC0000000000000000UC01", name: "Main Bank", notes: nil,
			type: "bank_account", color: "#24389C", initialBalance: "12480", balance: "12480",
			isDefault: false, createdAt: nil, updatedAt: nil, deletedAt: nil
		),
		Account.Response.AccountItem(
			id: "01K3AC0000000000000000AC03", userId: "01K3US0000000000000000US01",
			userCurrencyId: "01K3UC0000000000000000UC01", name: "Credit Card", notes: nil,
			type: "credit_card", color: "#6B7280", initialBalance: "0", balance: "0",
			isDefault: false, createdAt: nil, updatedAt: nil, deletedAt: nil
		)
	]
}
