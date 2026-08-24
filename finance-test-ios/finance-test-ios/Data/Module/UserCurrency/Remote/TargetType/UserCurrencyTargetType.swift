//
//  UserCurrencyTargetType.swift
//  finance-test-ios
//

import Foundation
import Moya
import Alamofire

enum UserCurrencyTargetType {
	case getUserCurrencies(UserCurrency.Request.GetUserCurrencies)
	case createUserCurrency(UserCurrency.Request.CreateUserCurrency)
}

extension UserCurrencyTargetType: BaseTargetType, AccessTokenAuthorizable {

	var authorizationType: AuthorizationType? {
		.bearer
	}

	var headers: [String: String]? {
		switch self {
		case .getUserCurrencies:
			[
				"Accept": "application/json"
			]
		case .createUserCurrency:
			[
				"Accept": "application/json",
				"Content-Type": "application/json"
			]
		}
	}

	var method: Moya.Method {
		switch self {
		case .getUserCurrencies:
			.get
		case .createUserCurrency:
			.post
		}
	}

	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .getUserCurrencies:
			return URLEncoding.default
		case .createUserCurrency:
			return JSONEncoding.default
		}
	}

	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}

	var parameters: [String: Any] {
		switch self {
		case .getUserCurrencies(let request):
			return request.toJSON()
		case .createUserCurrency(let request):
			return request.toJSON()
		}
	}

	var path: String {
		switch self {
		case .getUserCurrencies, .createUserCurrency:
			return "/user-currencies"
		}
	}

	var sampleData: Data {
		switch self {
		case .getUserCurrencies:
			let response = GeneralResponse(
				success: true,
				statusCode: 200,
				message: "",
				data: UserCurrency.Response.UserCurrencyList(
					items: UserCurrency.Response.UserCurrencyItem.mocks,
					serverTime: "2026-07-23T00:00:00Z"
				)
			)
			return response.toJSONData()
		case .createUserCurrency:
			let response = GeneralResponse(
				success: true,
				statusCode: 201,
				message: "",
				data: UserCurrency.Response.UserCurrencyItem.mocks.first
			)
			return response.toJSONData()
		}
	}
}
