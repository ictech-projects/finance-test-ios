//
//  Sync.swift
//  finance-test-ios
//

import Foundation

enum Sync {
	enum Request {}
	enum Response {}
}

extension Sync.Request {

	/// One item in a `/sync/push` batch. `id` is a client-generated ULID — `create`/`update` upsert
	/// by it, so retries are safe. `data` carries the entity-specific payload; `Sync` itself is
	/// entity-agnostic, so callers embed their own strongly-typed request via `JSONValue(encoding:)`.
	struct Change: Encodable, Equatable {
		let clientChangeId: String
		let entity: String
		let op: String
		let id: String
		let data: JSONValue?

		enum CodingKeys: String, CodingKey {
			case clientChangeId = "client_change_id"
			case entity, op, id, data
		}
	}

	struct Push: Encodable, Equatable {
		let changes: [Change]
	}

	/// Query params for `GET /sync/pull` — the offline-first batch read counterpart to `push`.
	/// Omit `since` for an initial sync (all current records); pass the previous pull's
	/// `server_time` for a delta sync (only records changed since, including soft-deleted
	/// tombstones).
	struct Pull: Codable, Equatable {
		let since: String?
		let limit: Int?
	}
}

extension Sync.Response {

	struct ChangeError: Codable, Equatable {
		let message: String?
		let errors: [String: [String]]?
	}

	/// `record` mirrors whatever entity was written (a `TransactionResource`, `AccountResource`, …) —
	/// decode it with `JSONValue.decoded(as:)` once the caller knows which entity it asked for.
	struct ChangeResult: Codable, Equatable {
		let clientChangeId: String?
		let id: String?
		let entity: String?
		let status: String?
		let record: JSONValue?
		let error: ChangeError?

		enum CodingKeys: String, CodingKey {
			case clientChangeId = "client_change_id"
			case id, entity, status, record, error
		}
	}

	struct PushResult: Codable, Equatable {
		let results: [ChangeResult]?
		let serverTime: String?

		enum CodingKeys: String, CodingKey {
			case results
			case serverTime = "server_time"
		}
	}

	/// Mirrors the `UserCategoryResource` schema — a user's own custom category, distinct from
	/// the read-only global `TransactionCategory.Response.CategoryItem`.
	struct UserCategoryItem: Codable, Equatable, Hashable {
		let id: String?
		let userId: String?
		let name: String?
		let type: TransactionType?
		let icon: String?
		let color: String?
		let createdAt: String?
		let updatedAt: String?
		let deletedAt: String?

		enum CodingKeys: String, CodingKey {
			case id
			case userId = "user_id"
			case name, type, icon, color
			case createdAt = "created_at"
			case updatedAt = "updated_at"
			case deletedAt = "deleted_at"
		}
	}

	/// `GET /sync/pull` returns every entity the client tracks in one payload — `currencies`,
	/// `categories`, `user_currencies`, `accounts`, `transactions`, `transfers`, `liabilities`,
	/// `liability_payments`, etc. Only `user_categories` has a consumer today, so only that field
	/// (plus `server_time`, needed for the next delta pull) is modeled — Decodable ignores the
	/// rest of the payload's keys.
	struct Pull: Codable, Equatable {
		let userCategories: [UserCategoryItem]?
		let serverTime: String?

		enum CodingKeys: String, CodingKey {
			case userCategories = "user_categories"
			case serverTime = "server_time"
		}
	}
}
