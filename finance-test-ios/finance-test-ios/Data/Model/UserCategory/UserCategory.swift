//
//  UserCategory.swift
//  finance-test-ios
//

import Foundation

/// A user's own custom transaction category, distinct from the read-only global
/// `TransactionCategory`. There is no dedicated REST resource for this domain — it exists only as
/// the `user_category` entity on the shared `/sync/push` (write) and `/sync/pull` (read)
/// endpoints, so its only response representation is `Sync.Response.UserCategoryItem`.
enum UserCategory {
	enum Request {}
}

extension UserCategory.Request {

	struct CreateUserCategory: Codable, Equatable {
		let name: String
		let type: TransactionType
		let icon: String
		let color: String?
	}
}
