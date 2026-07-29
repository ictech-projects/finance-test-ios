//
//  TransactionCategoryTargetType.swift
//  finance-test-ios
//

import Foundation
import Moya
import Alamofire

enum TransactionCategoryTargetType {
	case getCategories(TransactionCategory.Request.GetCategories)
}

extension TransactionCategoryTargetType: BaseTargetType, AccessTokenAuthorizable {

	var authorizationType: AuthorizationType? {
		.bearer
	}

	var headers: [String: String]? {
		switch self {
		case .getCategories:
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
		case .getCategories:
			return URLEncoding.default
		}
	}

	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}

	var parameters: [String: Any] {
		switch self {
		case .getCategories(let request):
			return request.toJSON()
		}
	}

	var path: String {
		switch self {
		case .getCategories:
			return "/categories"
		}
	}

	var sampleData: Data {
		switch self {
		case .getCategories:
			let response = GeneralResponse(
				success: true,
				statusCode: 200,
				message: "",
				data: TransactionCategory.Response.CategoryList(
					items: TransactionCategory.Response.CategoryItem.mocks,
					serverTime: "2026-07-23T00:00:00Z"
				)
			)
			return response.toJSONData()
		}
	}
}
