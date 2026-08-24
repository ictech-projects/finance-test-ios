//
//  ReportsCategoryBreakdown.swift
//  finance-test-ios
//

import SwiftUI

struct ReportsCategoryBreakdown: Identifiable {
	let id = UUID()
	let name: String
	var percent: Double
	let color: Color
}
