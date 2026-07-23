//
//  Double+currencyFormatted.swift
//  finance-test-ios
//

import Foundation

extension Double {
	func currencyFormatted(showsSign: Bool = false) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencySymbol = "$"
		formatter.minimumFractionDigits = 2
		formatter.maximumFractionDigits = 2
		formatter.positivePrefix = showsSign ? "+" : ""

		return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
	}

	func currencyWholeFormatted() -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencySymbol = "$"
		formatter.minimumFractionDigits = 0
		formatter.maximumFractionDigits = 0

		return formatter.string(from: NSNumber(value: self)) ?? "$0"
	}
}
