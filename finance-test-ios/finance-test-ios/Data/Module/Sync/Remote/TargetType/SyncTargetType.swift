//
//  SyncTargetType.swift
//  finance-test-ios
//

import Foundation
import Moya
import Alamofire

enum SyncTargetType {
	case push(Sync.Request.Push)
}

extension SyncTargetType: BaseTargetType, AccessTokenAuthorizable {

	var authorizationType: AuthorizationType? {
		.bearer
	}

	var headers: [String: String]? {
		switch self {
		case .push:
			[
				"Accept": "application/json",
				"Content-Type": "application/json"
			]
		}
	}

	var method: Moya.Method {
		.post
	}

	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .push:
			return JSONEncoding.default
		}
	}

	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}

	var parameters: [String: Any] {
		switch self {
		case .push(let request):
			return request.toJSON()
		}
	}

	var path: String {
		switch self {
		case .push:
			return "/sync/push"
		}
	}

	var sampleData: Data {
		switch self {
		case .push:
			let response = GeneralResponse(
				success: true,
				statusCode: 200,
				message: "",
				data: Sync.Response.PushResult(
					results: [
						Sync.Response.ChangeResult(
							clientChangeId: "c1",
							id: "01K3TX0000000000000000TX01",
							entity: "transaction",
							status: "applied",
							record: try? JSONValue(encoding: TransactionRecord.Response.TransactionItem.lunch),
							error: nil
						)
					],
					serverTime: "2026-07-27T00:00:00Z"
				)
			)
			return response.toJSONData()
		}
	}
}
