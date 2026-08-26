//
//  TransactionCategoryEntity.swift
//  finance-test-ios
//

import AppIntents

/// Lets Siri/Shortcuts list and disambiguate the user's expense categories for
/// `AddExpenseIntent`'s optional `category` parameter.
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
	private let categoryRepository: any TransactionCategoryRepository

	init() {
		self.init(categoryRepository: TransactionCategoryDefaultRepository())
	}

	init(categoryRepository: some TransactionCategoryRepository) {
		self.categoryRepository = categoryRepository
	}

	func entities(for identifiers: [String]) async throws -> [TransactionCategoryEntity] {
		try await allCategories().filter { identifiers.contains($0.id) }
	}

	func suggestedEntities() async throws -> [TransactionCategoryEntity] {
		try await allCategories()
	}

	private func allCategories() async throws -> [TransactionCategoryEntity] {
		let state = try await categoryRepository.getCategories(request: .init(type: .expense, since: nil))
		guard case .loaded(let response) = state else { return [] }
		return (response.data?.items ?? []).compactMap { item in
			guard let id = item.id, let name = item.name else { return nil }
			return TransactionCategoryEntity(id: id, name: name)
		}
	}
}
