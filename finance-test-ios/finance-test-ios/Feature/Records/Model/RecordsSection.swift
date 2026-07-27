//
//  RecordsSection.swift
//  finance-test-ios
//

import Foundation

struct RecordsSection: Identifiable, Equatable {
	let id: String
	let title: String
	let subtitle: String
	let items: [RecordsRowDisplay]
}

extension RecordsSection {
	static let mocks: [RecordsSection] = [
		RecordsSection(id: "today", title: "Today", subtitle: "Jul 27, 2026", items: RecordsRowDisplay.mocks)
	]
}
