//
//  TransactionTargetType.swift
//  finance-test-ios
//

import Foundation
import Moya
import Alamofire

enum TransactionTargetType {
	case getTransactions(TransactionRecord.Request.GetTransactions)
}

extension TransactionTargetType: BaseTargetType, AccessTokenAuthorizable {

	var authorizationType: AuthorizationType? {
		.bearer
	}

	var headers: [String: String]? {
		switch self {
		case .getTransactions:
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
		case .getTransactions:
			return URLEncoding.default
		}
	}

	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}

	var parameters: [String: Any] {
		switch self {
		case .getTransactions(let request):
			return request.toJSON()
		}
	}

	var path: String {
		switch self {
		case .getTransactions:
			return "/transactions"
		}
	}

	var sampleData: Data {
		switch self {
		case .getTransactions:
			let response = GeneralResponse(
				success: true,
				statusCode: 200,
				message: "",
				data: TransactionRecord.Response.TransactionList(
					items: TransactionRecord.Response.TransactionItem.mocks,
					serverTime: "2026-07-27T00:00:00Z"
				)
			)
			return response.toJSONData()
		}
	}
}
