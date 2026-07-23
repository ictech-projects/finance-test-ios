//
//  TransactionItem.swift
//  finance-test-ios
//

import Foundation

struct TransactionItem: Identifiable {
	let id = UUID()
	let title: String
	let merchant: String
	let amount: Double
	let account: String
	let dateLabel: String
	let iconName: String

	var isCredit: Bool { amount >= 0 }
}

extension TransactionItem {
	static let mocks: [TransactionItem] = [
		TransactionItem(title: "Grocery", merchant: "Whole Foods Market", amount: -142.50, account: "Checking", dateLabel: "Today", iconName: "cart.fill"),
		TransactionItem(title: "Salary", merchant: "Tech Solutions Corp", amount: 5_200.00, account: "Savings", dateLabel: "Yesterday", iconName: "banknote.fill"),
		TransactionItem(title: "Rent", merchant: "Skyline Apartments", amount: -1_800.00, account: "Checking", dateLabel: "Oct 1", iconName: "house.fill"),
		TransactionItem(title: "Coffee", merchant: "Starbucks", amount: -6.45, account: "Credit Card", dateLabel: "Sep 28", iconName: "cup.and.saucer.fill"),
		TransactionItem(title: "Internet", merchant: "Comcast Xfinity", amount: -89.99, account: "Checking", dateLabel: "Sep 25", iconName: "wifi")
	]
}
