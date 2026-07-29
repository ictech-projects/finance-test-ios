//
//  AuthDefaultLocalDataSource.swift
//  finance-test-ios
//

import Foundation

struct AuthDefaultLocalDataSource: AuthLocalDataSource {

	private let keychain: KeychainHelper

	init(keychain: KeychainHelper = .shared) {
		self.keychain = keychain
	}

	func saveSession(accessToken: String, refreshToken: String) {
		keychain.save(accessToken, for: KeychainKey.accessToken.key)
		keychain.save(refreshToken, for: KeychainKey.refreshToken.key)
	}

	func getAccessToken() -> String? {
		keychain.getString(for: KeychainKey.accessToken.key)
	}

	func getRefreshToken() -> String? {
		keychain.getString(for: KeychainKey.refreshToken.key)
	}

	func clearSession() {
		keychain.delete(for: KeychainKey.accessToken.key)
		keychain.delete(for: KeychainKey.refreshToken.key)
	}
}
