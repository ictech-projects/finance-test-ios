//
//  UserCurrency.swift
//  finance-test-ios
//

import Foundation

enum UserCurrency {
	enum Request {}
	enum Response {}
}

extension UserCurrency.Request {

	struct GetUserCurrencies: Codable, Equatable {
		let since: String?
	}

	struct CreateUserCurrency: Codable, Equatable {
		let currencyId: String
		let exchangeRate: String?
		let isAnchor: Bool?

		enum CodingKeys: String, CodingKey {
			case currencyId = "currency_id"
			case exchangeRate = "exchange_rate"
			case isAnchor = "is_anchor"
		}
	}

	/// Same wire shape as `CreateUserCurrency` — the backend has no `PATCH /user-currencies/{id}`,
	/// so an update is submitted as a `user_currency`/`update` change via `/sync/push` instead (see
	/// `UserCurrencyDefaultRepository.updateUserCurrency`). Kept as its own type so call sites read
	/// as "update", matching this codebase's request-naming convention.
	struct UpdateUserCurrency: Codable, Equatable {
		let currencyId: String
		let exchangeRate: String?
		let isAnchor: Bool?

		enum CodingKeys: String, CodingKey {
			case currencyId = "currency_id"
			case exchangeRate = "exchange_rate"
			case isAnchor = "is_anchor"
		}
	}
}

extension UserCurrency.Response {

	struct UserCurrencyItem: Codable, Equatable, Hashable {
		let id: String?
		let userId: String?
		let currencyId: String?
		let exchangeRate: String?
		let isAnchor: Bool?
		let createdAt: String?
		let updatedAt: String?

		enum CodingKeys: String, CodingKey {
			case id
			case userId = "user_id"
			case currencyId = "currency_id"
			case exchangeRate = "exchange_rate"
			case isAnchor = "is_anchor"
			case createdAt = "created_at"
			case updatedAt = "updated_at"
		}
	}

	struct UserCurrencyList: Codable, Equatable, Hashable {
		let items: [UserCurrencyItem]?
		let serverTime: String?

		enum CodingKeys: String, CodingKey {
			case items
			case serverTime = "server_time"
		}
	}
}

extension UserCurrency.Response.UserCurrencyItem {
	/// Reuses the same `user_currency` id `Account.Response.AccountItem.mocks` already references
	/// via `userCurrencyId`, so mock accounts and mock user currencies stay consistent.
	static let mocks: [UserCurrency.Response.UserCurrencyItem] = [
		UserCurrency.Response.UserCurrencyItem(
			id: "01K3UC0000000000000000UC01", userId: "01K3US0000000000000000US01",
			currencyId: "usd", exchangeRate: "1", isAnchor: true,
			createdAt: nil, updatedAt: nil
		),
		UserCurrency.Response.UserCurrencyItem(
			id: "01K3UC0000000000000000UC02", userId: "01K3US0000000000000000US01",
			currencyId: "eur", exchangeRate: "0.9245", isAnchor: false,
			createdAt: nil, updatedAt: nil
		),
		UserCurrency.Response.UserCurrencyItem(
			id: "01K3UC0000000000000000UC03", userId: "01K3US0000000000000000US01",
			currencyId: "gbp", exchangeRate: "0.7912", isAnchor: false,
			createdAt: nil, updatedAt: nil
		)
	]
}
