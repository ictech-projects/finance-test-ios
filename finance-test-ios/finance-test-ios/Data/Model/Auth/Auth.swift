//
//  Auth.swift
//  finance-test-ios
//

import Foundation

enum Auth {
	enum Request {}
	enum Response {}
}

extension Auth.Request {

	struct Register: Codable, Equatable {
		let name: String
		let email: String
		let password: String
		let passwordConfirmation: String

		enum CodingKeys: String, CodingKey {
			case name, email, password
			case passwordConfirmation = "password_confirmation"
		}
	}

	struct Login: Codable, Equatable {
		let email: String
		let password: String
	}

	struct Refresh: Codable, Equatable {
		let refreshToken: String

		enum CodingKeys: String, CodingKey {
			case refreshToken = "refresh_token"
		}
	}
}

extension Auth.Response {

	struct User: Codable, Equatable, Hashable {
		let id: String
		let name: String
		let email: String
		let role: String
		let avatarPath: String?
		let avatarUrl: String?
		let emailVerifiedAt: String?
		let createdAt: String?
		let updatedAt: String?

		enum CodingKeys: String, CodingKey {
			case id, name, email, role
			case avatarPath = "avatar_path"
			case avatarUrl = "avatar_url"
			case emailVerifiedAt = "email_verified_at"
			case createdAt = "created_at"
			case updatedAt = "updated_at"
		}
	}

	struct Session: Codable, Equatable {
		let user: User
		let token: String
		let refreshToken: String
		let refreshExpiresAt: String

		enum CodingKeys: String, CodingKey {
			case user, token
			case refreshToken = "refresh_token"
			case refreshExpiresAt = "refresh_expires_at"
		}
	}

	struct Profile: Codable, Equatable {
		let user: User
	}
}

extension Auth.Response.User {
	static let mock = Auth.Response.User(
		id: "1",
		name: "Jane Doe",
		email: "jane.doe@example.com",
		role: "member",
		avatarPath: nil,
		avatarUrl: nil,
		emailVerifiedAt: nil,
		createdAt: nil,
		updatedAt: nil
	)
}

extension Auth.Response.Session {
	static let mock = Auth.Response.Session(
		user: .mock,
		token: "mock-access-token",
		refreshToken: "mock-refresh-token",
		refreshExpiresAt: "2026-12-31T00:00:00Z"
	)
}
