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
}
