//
//  SyncTargetType.swift
//  finance-test-ios
//

import Foundation
import Moya
import Alamofire

enum SyncTargetType {
	case push(Sync.Request.Push)
	case pull(Sync.Request.Pull)
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
		case .pull:
			[
				"Accept": "application/json"
			]
		}
	}

	var method: Moya.Method {
		switch self {
		case .push:
			.post
		case .pull:
			.get
		}
	}

	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .push:
			return JSONEncoding.default
		case .pull:
			return URLEncoding.default
		}
	}

	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}

	var parameters: [String: Any] {
		switch self {
		case .push(let request):
			return request.toJSON()
		case .pull(let request):
			return request.toJSON()
		}
	}

	var path: String {
		switch self {
		case .push:
			return "/sync/push"
		case .pull:
			return "/sync/pull"
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
		case .pull:
			let response = GeneralResponse(
				success: true,
				statusCode: 200,
				message: "",
				data: Sync.Response.Pull(
					userCategories: [
						Sync.Response.UserCategoryItem(
							id: "01K3UT0000000000000000UT01", userId: "01K3US0000000000000000US01",
							name: "Side Hustle", type: .income, icon: "briefcase", color: "#24389C",
							createdAt: nil, updatedAt: nil, deletedAt: nil
						)
					],
					serverTime: "2026-07-27T00:00:00Z"
				)
			)
			return response.toJSONData()
		}
	}
}
