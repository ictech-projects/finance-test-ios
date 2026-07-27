//
//  RecordsTypeFilter.swift
//  finance-test-ios
//

import Foundation

enum RecordsTypeFilter: String, CaseIterable, Identifiable {
	case all = "All"
	case income = "Income"
	case expense = "Expense"

	var id: String { rawValue }
}
