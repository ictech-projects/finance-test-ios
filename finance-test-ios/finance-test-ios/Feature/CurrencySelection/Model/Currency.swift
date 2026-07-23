//
//  Currency.swift
//  finance-test-ios
//

import Foundation

struct Currency: Identifiable, Equatable {
	let id: String
	let symbol: String
	let name: String

	var code: String { id }
}

extension Currency {
	static let usd = Currency(id: "USD", symbol: "$", name: "US Dollar")

	static let mocks: [Currency] = [
		.usd,
		Currency(id: "EUR", symbol: "€", name: "Euro"),
		Currency(id: "GBP", symbol: "£", name: "British Pound"),
		Currency(id: "JPY", symbol: "¥", name: "Japanese Yen")
	]
}
