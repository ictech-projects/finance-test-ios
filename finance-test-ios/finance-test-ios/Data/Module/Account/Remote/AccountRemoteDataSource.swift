//
//  AccountRemoteDataSource.swift
//  finance-test-ios
//

import Foundation

protocol AccountRemoteDataSource {
	func getAccounts(
		request: Account.Request.GetAccounts
	) async throws -> GeneralResponse<Account.Response.AccountList>
}
