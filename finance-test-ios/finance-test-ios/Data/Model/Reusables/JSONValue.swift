//
//  JSONValue.swift
// finance-test-ios
//

import Foundation

/// Represents an arbitrary JSON value. Used where the backend contract is intentionally dynamic —
/// e.g. `/sync/push`'s `data`/`record` fields, whose shape depends on the `entity` being written.
enum JSONValue: Equatable {
	case string(String)
	case number(Double)
	case bool(Bool)
	case object([String: JSONValue])
	case array([JSONValue])
	case null
}

extension JSONValue: Codable {
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()

		if container.decodeNil() {
			self = .null
		} else if let value = try? container.decode(Bool.self) {
			self = .bool(value)
		} else if let value = try? container.decode(Double.self) {
			self = .number(value)
		} else if let value = try? container.decode(String.self) {
			self = .string(value)
		} else if let value = try? container.decode([String: JSONValue].self) {
			self = .object(value)
		} else if let value = try? container.decode([JSONValue].self) {
			self = .array(value)
		} else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON value")
		}
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()

		switch self {
		case .string(let value): try container.encode(value)
		case .number(let value): try container.encode(value)
		case .bool(let value): try container.encode(value)
		case .object(let value): try container.encode(value)
		case .array(let value): try container.encode(value)
		case .null: try container.encodeNil()
		}
	}
}

extension JSONValue {
	/// Round-trips any `Encodable` value through JSON to embed it in a dynamic field
	/// (e.g. `sync/push`'s `data`).
	init(encoding value: some Encodable) throws {
		self = try JSONDecoder().decode(JSONValue.self, from: JSONEncoder().encode(value))
	}

	/// Reverse of `init(encoding:)` — decodes a dynamic value (e.g. `sync/push`'s per-entity
	/// `record`) back into a strongly-typed model.
	func decoded<T: Decodable>(as type: T.Type = T.self) throws -> T {
		try JSONDecoder().decode(type, from: JSONEncoder().encode(self))
	}
}
