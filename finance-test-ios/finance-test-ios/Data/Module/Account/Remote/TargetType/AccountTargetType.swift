//
//  AccountTargetType.swift
//  finance-test-ios
//

import Foundation
import Moya
import Alamofire

enum AccountTargetType {
	case getAccounts(Account.Request.GetAccounts)
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
		}
	}

	var method: Moya.Method {
		.get
	}

	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .getAccounts:
			return URLEncoding.default
		}
	}

	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}

	var parameters: [String: Any] {
		switch self {
		case .getAccounts(let request):
			return request.toJSON()
		}
	}

	var path: String {
		switch self {
		case .getAccounts:
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
		}
	}
}
