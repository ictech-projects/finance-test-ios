//
//  AccountRemoteDataSource.swift
//  finance-test-ios
//

import Foundation

protocol AccountRemoteDataSource {
	func getAccounts(
		request: Account.Request.GetAccounts
	) async throws -> GeneralResponse<Account.Response.AccountList>

	func createAccount(
		request: Account.Request.CreateAccount
	) async throws -> GeneralResponse<Account.Response.AccountItem>
}
