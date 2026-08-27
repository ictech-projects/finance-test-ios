//
//  TransactionCategoryEntity.swift
//  finance-test-ios
//

import AppIntents

/// Lets Siri/Shortcuts list and disambiguate the user's expense categories for
/// `AddExpenseIntent`'s `category` parameter.
///
/// Backed by the user's own categories (`UserCategoryRepository`), not the global
/// `GET /categories` catalog: a transaction's `category_id` must reference a user category, so
/// offering global ids here means whatever the user picks fails to match downstream.
struct TransactionCategoryEntity: AppEntity {
	let id: String
	let name: String

	static var typeDisplayRepresentation: TypeDisplayRepresentation = "Category"
	static var defaultQuery = TransactionCategoryEntityQuery()

	var displayRepresentation: DisplayRepresentation {
		DisplayRepresentation(title: "\(name)")
	}
}

struct TransactionCategoryEntityQuery: EntityQuery {
	private let categoryRepository: any UserCategoryRepository

	init() {
		self.init(categoryRepository: UserCategoryDefaultRepository())
	}

	init(categoryRepository: some UserCategoryRepository) {
		self.categoryRepository = categoryRepository
	}

	func entities(for identifiers: [String]) async throws -> [TransactionCategoryEntity] {
		try await allCategories().filter { identifiers.contains($0.id) }
	}

	func suggestedEntities() async throws -> [TransactionCategoryEntity] {
		try await allCategories()
	}

	private func allCategories() async throws -> [TransactionCategoryEntity] {
		let state = try await categoryRepository.getUserCategories()
		guard case .loaded(let response) = state else { return [] }
		return (response.data ?? [])
			.filter { $0.type == .expense && $0.deletedAt == nil }
			.compactMap { item in
				guard let id = item.id, let name = item.name else { return nil }
				return TransactionCategoryEntity(id: id, name: name)
			}
	}
}
