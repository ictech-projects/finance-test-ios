//
//  DisplayCurrency.swift
//  finance-test-ios
//

import Foundation

/// The currency amounts are rendered in — just the three things formatting needs, so the
/// formatter doesn't depend on the whole `Currency.Response.CurrencyItem` wire model.
struct DisplayCurrency: Equatable, Sendable {
	let code: String
	let symbol: String
	let decimalPlaces: Int

	/// Used before the user's currencies have loaded, and when a currency arrives with fields
	/// missing. Matches `Currency.Response.CurrencyItem.usd`.
	static let fallback = DisplayCurrency(code: "USD", symbol: "$", decimalPlaces: 2)

	init(code: String, symbol: String, decimalPlaces: Int) {
		self.code = code
		self.symbol = symbol
		self.decimalPlaces = decimalPlaces
	}

	/// Every field on the wire model is optional, so anything absent falls back rather than
	/// rendering an empty symbol or a nonsensical fraction count.
	init(item: Currency.Response.CurrencyItem) {
		self.code = item.code ?? Self.fallback.code
		self.symbol = item.symbol ?? Self.fallback.symbol
		self.decimalPlaces = item.decimalPlaces ?? Self.fallback.decimalPlaces
	}
}

extension DisplayCurrency {

	/// The value `Double.currencyFormatted` defaults to.
	///
	/// `DisplayCurrencyStore` is `@MainActor` (it publishes to Views), but formatting is a plain
	/// synchronous call. Rather than make every call site `await`, the store mirrors its resolved
	/// value here behind a lock — writes happen once on load, reads happen on every row render.
	static var current: DisplayCurrency { currentBox.value }

	/// Only `DisplayCurrencyDefaultStore` should call this; it keeps the two in step.
	static func setCurrent(_ currency: DisplayCurrency) {
		currentBox.value = currency
	}

	private static let currentBox = LockedBox<DisplayCurrency>(.fallback)
}

/// Minimal lock-protected holder — `DisplayCurrency` is a small value type read from any thread
/// and written rarely, so a lock is cheaper and simpler than actor hops on every render.
private final class LockedBox<Value>: @unchecked Sendable {
	private var storage: Value
	private let lock = NSLock()

	init(_ value: Value) {
		self.storage = value
	}

	var value: Value {
		get {
			lock.lock()
			defer { lock.unlock() }
			return storage
		}
		set {
			lock.lock()
			defer { lock.unlock() }
			storage = newValue
		}
	}
}
