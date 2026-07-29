//
//  AuthTargetType.swift
//  finance-test-ios
//

import Foundation
import Moya
import Alamofire

enum AuthTargetType {
	case register(Auth.Request.Register)
	case login(Auth.Request.Login)
	case refresh(Auth.Request.Refresh)
	case logout
	case logoutAll
	case getProfile
}

extension AuthTargetType: BaseTargetType, AccessTokenAuthorizable {

	var authorizationType: AuthorizationType? {
		switch self {
		case .register, .login, .refresh:
			nil
		case .logout, .logoutAll, .getProfile:
			.bearer
		}
	}

	var headers: [String: String]? {
		switch self {
		case .register, .login, .refresh:
			[
				"Accept": "application/json",
				"Content-Type": "application/json"
			]
		case .logout, .logoutAll, .getProfile:
			[
				"Accept": "application/json"
			]
		}
	}

	var method: Moya.Method {
		switch self {
		case .register, .login, .refresh, .logout, .logoutAll:
			.post
		case .getProfile:
			.get
		}
	}

	var parameterEncoding: Moya.ParameterEncoding {
		JSONEncoding.default
	}

	var task: Task {
		.requestParameters(parameters: parameters, encoding: parameterEncoding)
	}

	var parameters: [String: Any] {
		switch self {
		case .register(let request):
			request.toJSON()
		case .login(let request):
			request.toJSON()
		case .refresh(let request):
			request.toJSON()
		case .logout, .logoutAll, .getProfile:
			[:]
		}
	}

	var path: String {
		switch self {
		case .register:
			"/auth/register"
		case .login:
			"/auth/login"
		case .refresh:
			"/auth/refresh"
		case .logout:
			"/auth/logout"
		case .logoutAll:
			"/auth/logout-all"
		case .getProfile:
			"/auth/profile"
		}
	}

	var sampleData: Data {
		switch self {
		case .register:
			let response = GeneralResponse(
				success: true,
				statusCode: 201,
				message: "Registration successful.",
				data: Auth.Response.Session.mock
			)
			return response.toJSONData()
		case .login, .refresh:
			let response = GeneralResponse(
				success: true,
				statusCode: 200,
				message: "Login successful.",
				data: Auth.Response.Session.mock
			)
			return response.toJSONData()
		case .logout:
			let response = GeneralResponse(
				success: true,
				statusCode: 200,
				message: "Logged out.",
				data: EmptyData()
			)
			return response.toJSONData()
		case .logoutAll:
			let response = GeneralResponse(
				success: true,
				statusCode: 200,
				message: "Logged out from all devices.",
				data: EmptyData()
			)
			return response.toJSONData()
		case .getProfile:
			let response = GeneralResponse(
				success: true,
				statusCode: 200,
				message: "Profile fetched.",
				data: Auth.Response.Profile(user: .mock)
			)
			return response.toJSONData()
		}
	}
}
