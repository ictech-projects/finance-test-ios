//
//  AccountEntity.swift
//  finance-test-ios
//

import AppIntents

/// Lets Siri/Shortcuts list and disambiguate the user's accounts for `AddExpenseIntent`'s
/// optional `account` parameter.
struct AccountEntity: AppEntity {
	let id: String
	let name: String

	static var typeDisplayRepresentation: TypeDisplayRepresentation = "Account"
	static var defaultQuery = AccountEntityQuery()

	var displayRepresentation: DisplayRepresentation {
		DisplayRepresentation(title: "\(name)")
	}
}

struct AccountEntityQuery: EntityQuery {
	private let accountRepository: any AccountRepository

	init() {
		self.init(accountRepository: AccountDefaultRepository())
	}

	init(accountRepository: some AccountRepository) {
		self.accountRepository = accountRepository
	}

	func entities(for identifiers: [String]) async throws -> [AccountEntity] {
		try await allAccounts().filter { identifiers.contains($0.id) }
	}

	func suggestedEntities() async throws -> [AccountEntity] {
		try await allAccounts()
	}

	private func allAccounts() async throws -> [AccountEntity] {
		let state = try await accountRepository.getAccounts(request: .init(since: nil))
		guard case .loaded(let response) = state else { return [] }
		return (response.data?.items ?? []).compactMap { item in
			guard let id = item.id, let name = item.name else { return nil }
			return AccountEntity(id: id, name: name)
		}
	}
}
