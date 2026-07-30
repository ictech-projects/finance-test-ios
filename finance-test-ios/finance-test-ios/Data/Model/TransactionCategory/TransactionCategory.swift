//
//  TransactionCategory.swift
//  finance-test-ios
//

import Foundation

/// Named `TransactionCategory` rather than `Category` — `Category` collides with
/// `ObjectiveC.Category` (a bridging typealias for `OpaquePointer`), which causes ambiguous
/// lookups in files that don't happen to shadow it.
enum TransactionCategory {
	enum Request {}
	enum Response {}
}

extension TransactionCategory.Request {

	struct GetCategories: Codable, Equatable {
		let type: TransactionType?
		let since: String?
	}
}

extension TransactionCategory.Response {

	struct CategoryItem: Codable, Equatable, Hashable {
		let id: String?
		let name: String?
		let type: TransactionType?
		let icon: String?
		let color: String?
		let createdAt: String?
		let updatedAt: String?
		let deletedAt: String?

		enum CodingKeys: String, CodingKey {
			case id, name, type, icon, color
			case createdAt = "created_at"
			case updatedAt = "updated_at"
			case deletedAt = "deleted_at"
		}
	}

	struct CategoryList: Codable, Equatable, Hashable {
		let items: [CategoryItem]?
		let serverTime: String?

		enum CodingKeys: String, CodingKey {
			case items
			case serverTime = "server_time"
		}
	}
}

extension TransactionCategory.Response.CategoryItem {
	/// Seeded from the same ids `RecordsCatalog` already uses, so Add Transaction's picker and
	/// Records' display stay visually consistent while both are mock-backed.
	static let mocks: [TransactionCategory.Response.CategoryItem] = [
		TransactionCategory.Response.CategoryItem(
			id: "01K3CT0000000000000000CT01", name: "Dining & Drinks", type: .expense,
			icon: "fork.knife", color: "#F97316", createdAt: nil, updatedAt: nil, deletedAt: nil
		),
		TransactionCategory.Response.CategoryItem(
			id: "01K3CT0000000000000000CT02", name: "Freelance Income", type: .income,
			icon: "camera", color: "#24389C", createdAt: nil, updatedAt: nil, deletedAt: nil
		),
		TransactionCategory.Response.CategoryItem(
			id: "01K3CT0000000000000000CT03", name: "Transport", type: .expense,
			icon: "car", color: "#6B7280", createdAt: nil, updatedAt: nil, deletedAt: nil
		),
		TransactionCategory.Response.CategoryItem(
			id: "01K3CT0000000000000000CT04", name: "Groceries", type: .expense,
			icon: "cart", color: "#6B7280", createdAt: nil, updatedAt: nil, deletedAt: nil
		),
		TransactionCategory.Response.CategoryItem(
			id: "01K3CT0000000000000000CT05", name: "Entertainment", type: .expense,
			icon: "film", color: "#6B7280", createdAt: nil, updatedAt: nil, deletedAt: nil
		)
	]
}
