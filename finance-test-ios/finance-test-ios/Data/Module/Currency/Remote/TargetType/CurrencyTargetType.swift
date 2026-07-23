//
//  CurrencyTargetType.swift
//  finance-test-ios
//

import Foundation
import Moya
import Alamofire

enum CurrencyTargetType {
	case getCurrencies(Currency.Request.GetCurrencies)
}

extension CurrencyTargetType: BaseTargetType, AccessTokenAuthorizable {

	var authorizationType: AuthorizationType? {
		.bearer
	}

	var headers: [String: String]? {
		switch self {
		case .getCurrencies:
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
		case .getCurrencies:
			return URLEncoding.default
		}
	}

	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}

	var parameters: [String: Any] {
		switch self {
		case .getCurrencies(let request):
			return request.toJSON()
		}
	}

	var path: String {
		switch self {
		case .getCurrencies:
			return "/currencies"
		}
	}

	var sampleData: Data {
		switch self {
		case .getCurrencies:
			let response = GeneralResponse(
				success: true,
				statusCode: 200,
				message: "",
				data: Currency.Response.CurrencyList(
					items: Currency.Response.CurrencyItem.mocks,
					serverTime: "2026-07-23T00:00:00Z"
				)
			)
			return response.toJSONData()
		}
	}
}
