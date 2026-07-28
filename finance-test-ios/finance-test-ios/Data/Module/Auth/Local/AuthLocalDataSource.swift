//
//  AuthLocalDataSource.swift
//  finance-test-ios
//

import Foundation

protocol AuthLocalDataSource {
	func saveSession(accessToken: String, refreshToken: String)
	func getAccessToken() -> String?
	func getRefreshToken() -> String?
	func clearSession()
}
