//
//  Double+currencyFormatted.swift
//  finance-test-ios
//

import Foundation

extension Double {
	/// Uses `.decimal` style with a manually prepended "$" rather than `.currency` style with an
	/// overridden `currencySymbol` — under some device regions (e.g. `en_ID`), `.currency` style
	/// silently drops a manually-set `currencySymbol` even with `locale` pinned to `en_US`.
	/// `.decimal` style has no currency-symbol-pattern derivation to go wrong.
	func currencyFormatted(showsSign: Bool = false) -> String {
		let formatter = NumberFormatter()
		formatter.locale = Locale(identifier: "en_US")
		formatter.numberStyle = .decimal
		formatter.minimumFractionDigits = 2
		formatter.maximumFractionDigits = 2

		let magnitude = formatter.string(from: NSNumber(value: abs(self))) ?? "0.00"
		let sign = self < 0 ? "-" : (showsSign ? "+" : "")
		return "\(sign)$\(magnitude)"
	}

	func currencyWholeFormatted() -> String {
		let formatter = NumberFormatter()
		formatter.locale = Locale(identifier: "en_US")
		formatter.numberStyle = .decimal
		formatter.minimumFractionDigits = 0
		formatter.maximumFractionDigits = 0

		let magnitude = formatter.string(from: NSNumber(value: abs(self))) ?? "0"
		let sign = self < 0 ? "-" : ""
		return "\(sign)$\(magnitude)"
	}
}
