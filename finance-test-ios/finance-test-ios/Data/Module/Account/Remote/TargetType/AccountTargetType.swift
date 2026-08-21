//
//  AccountTargetType.swift
//  finance-test-ios
//

import Foundation
import Moya
import Alamofire

enum AccountTargetType {
	case getAccounts(Account.Request.GetAccounts)
	case createAccount(Account.Request.CreateAccount)
}

extension AccountTargetType: BaseTargetType, AccessTokenAuthorizable {

	var authorizationType: AuthorizationType? {
		.bearer
	}

	var headers: [String: String]? {
		switch self {
		case .getAccounts:
			[
				"Accept": "application/json"
			]
		case .createAccount:
			[
				"Accept": "application/json",
				"Content-Type": "application/json"
			]
		}
	}

	var method: Moya.Method {
		switch self {
		case .getAccounts:
			.get
		case .createAccount:
			.post
		}
	}

	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .getAccounts:
			return URLEncoding.default
		case .createAccount:
			return JSONEncoding.default
		}
	}

	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}

	var parameters: [String: Any] {
		switch self {
		case .getAccounts(let request):
			return request.toJSON()
		case .createAccount(let request):
			return request.toJSON()
		}
	}

	var path: String {
		switch self {
		case .getAccounts, .createAccount:
			return "/accounts"
		}
	}

	var sampleData: Data {
		switch self {
		case .getAccounts:
			let response = GeneralResponse(
				success: true,
				statusCode: 200,
				message: "",
				data: Account.Response.AccountList(
					items: Account.Response.AccountItem.mocks,
					serverTime: "2026-07-23T00:00:00Z"
				)
			)
			return response.toJSONData()
		case .createAccount:
			let response = GeneralResponse(
				success: true,
				statusCode: 201,
				message: "",
				data: Account.Response.AccountItem.mocks.first
			)
			return response.toJSONData()
		}
	}
}
