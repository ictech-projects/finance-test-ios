//
//  HomeSummary.swift
//  finance-test-ios
//

import Foundation

struct HomeSummary {
	let balanceThisMonth: Double
	let netWorth: Double
	let income: Double
	let expense: Double
	let totalOwed: Double
	let owedLimit: Double

	var owedRatio: Double {
		guard owedLimit > 0 else { return 0 }
		return min(totalOwed / owedLimit, 1)
	}
}

extension HomeSummary {
	static let mock = HomeSummary(
		balanceThisMonth: 2_100,
		netWorth: 142_800,
		income: 5_200,
		expense: 3_100,
		totalOwed: 12_500,
		owedLimit: 28_000
	)
}
