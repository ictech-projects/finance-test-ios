//
//  Currency.swift
//  finance-test-ios
//

import Foundation

enum Currency {
	enum Request {}
	enum Response {}
}

extension Currency.Request {

	struct GetCurrencies: Codable {
		let since: String?
	}
}

extension Currency.Response {

	struct CurrencyItem: Codable, Equatable, Hashable {
		let id: String?
		let code: String?
		let name: String?
		let symbol: String?
		let decimalPlaces: Int?
		let createdAt: String?
		let updatedAt: String?
		let deletedAt: String?

		enum CodingKeys: String, CodingKey {
			case id, code, name, symbol
			case decimalPlaces = "decimal_places"
			case createdAt = "created_at"
			case updatedAt = "updated_at"
			case deletedAt = "deleted_at"
		}
	}

	struct CurrencyList: Codable, Equatable, Hashable {
		let items: [CurrencyItem]?
		let serverTime: String?

		enum CodingKeys: String, CodingKey {
			case items
			case serverTime = "server_time"
		}
	}
}

extension Currency.Response.CurrencyItem {
	static let usd = Currency.Response.CurrencyItem(
		id: "usd", code: "USD", name: "US Dollar", symbol: "$",
		decimalPlaces: 2, createdAt: nil, updatedAt: nil, deletedAt: nil
	)

	static let mocks: [Currency.Response.CurrencyItem] = [
		.usd,
		Currency.Response.CurrencyItem(
			id: "eur", code: "EUR", name: "Euro", symbol: "€",
			decimalPlaces: 2, createdAt: nil, updatedAt: nil, deletedAt: nil
		),
		Currency.Response.CurrencyItem(
			id: "gbp", code: "GBP", name: "British Pound", symbol: "£",
			decimalPlaces: 2, createdAt: nil, updatedAt: nil, deletedAt: nil
		),
		Currency.Response.CurrencyItem(
			id: "jpy", code: "JPY", name: "Japanese Yen", symbol: "¥",
			decimalPlaces: 0, createdAt: nil, updatedAt: nil, deletedAt: nil
		)
	]
}
