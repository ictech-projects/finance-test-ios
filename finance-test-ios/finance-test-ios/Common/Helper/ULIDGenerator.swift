//
//  ULIDGenerator.swift
//  finance-test-ios
//

import Foundation

/// Generates client-side [ULID](https://github.com/ulid/spec) identifiers. `POST /sync/push`
/// requires the caller to generate the id for every entity it creates — the server upserts by it,
/// so retries are safe.
enum ULIDGenerator {
	private static let encodingChars = Array("0123456789ABCDEFGHJKMNPQRSTVWXYZ")

	static func generate(date: Date = Date()) -> String {
		let timestamp = UInt64(max(date.timeIntervalSince1970, 0) * 1000)
		return encodeTime(timestamp) + encodeRandomness()
	}

	private static func encodeTime(_ timestamp: UInt64) -> String {
		var value = timestamp
		var characters = [Character](repeating: "0", count: 10)
		for index in stride(from: 9, through: 0, by: -1) {
			characters[index] = encodingChars[Int(value % 32)]
			value /= 32
		}
		return String(characters)
	}

	private static func encodeRandomness() -> String {
		String((0..<16).map { _ in encodingChars[Int.random(in: 0..<32)] })
	}
}
