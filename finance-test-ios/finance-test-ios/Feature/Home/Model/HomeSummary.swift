//
//  HomeSummary.swift
//  finance-test-ios
//

import Foundation

struct HomeSummary: Equatable {
	let balanceThisMonth: Double
	let netWorth: Double
	let income: Double
	let expense: Double
}

extension HomeSummary {
	static let empty = HomeSummary(balanceThisMonth: 0, netWorth: 0, income: 0, expense: 0)
}
