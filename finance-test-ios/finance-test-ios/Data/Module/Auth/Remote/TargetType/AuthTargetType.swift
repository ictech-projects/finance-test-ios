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
	case updateProfile(Auth.Request.UpdateProfile)
	case uploadAvatar(imageData: Data, fileName: String, mimeType: String)
	case deleteAvatar
}

extension AuthTargetType: BaseTargetType, AccessTokenAuthorizable {

	var authorizationType: AuthorizationType? {
		switch self {
		case .register, .login, .refresh:
			nil
		case .logout, .logoutAll, .getProfile, .updateProfile, .uploadAvatar, .deleteAvatar:
			.bearer
		}
	}

	var headers: [String: String]? {
		switch self {
		case .register, .login, .refresh, .updateProfile:
			[
				"Accept": "application/json",
				"Content-Type": "application/json"
			]
		case .logout, .logoutAll, .getProfile, .uploadAvatar, .deleteAvatar:
			[
				"Accept": "application/json"
			]
		}
	}

	var method: Moya.Method {
		switch self {
		case .register, .login, .refresh, .logout, .logoutAll, .uploadAvatar:
			.post
		case .getProfile:
			.get
		case .updateProfile:
			.put
		case .deleteAvatar:
			.delete
		}
	}

	var parameterEncoding: Moya.ParameterEncoding {
		JSONEncoding.default
	}

	var task: Task {
		switch self {
		case .register, .login, .refresh, .logout, .logoutAll, .updateProfile:
			.requestParameters(parameters: parameters, encoding: parameterEncoding)
		case .getProfile, .deleteAvatar:
			// GET/DELETE requests can't carry body data — JSONEncoding would otherwise attach an
			// empty `{}` body, which Alamofire's URLRequest validation rejects outright.
			.requestPlain
		case .uploadAvatar(let imageData, let fileName, let mimeType):
			.uploadMultipart([
				MultipartFormData(provider: .data(imageData), name: "avatar", fileName: fileName, mimeType: mimeType)
			])
		}
	}

	var parameters: [String: Any] {
		switch self {
		case .register(let request):
			request.toJSON()
		case .login(let request):
			request.toJSON()
		case .refresh(let request):
			request.toJSON()
		case .updateProfile(let request):
			request.toJSON()
		case .logout, .logoutAll, .getProfile, .uploadAvatar, .deleteAvatar:
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
		case .getProfile, .updateProfile:
			"/auth/profile"
		case .uploadAvatar, .deleteAvatar:
			"/auth/profile/avatar"
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
		case .updateProfile:
			let response = GeneralResponse(
				success: true,
				statusCode: 200,
				message: "Profile updated.",
				data: Auth.Response.Profile(user: .mock)
			)
			return response.toJSONData()
		case .uploadAvatar:
			let response = GeneralResponse(
				success: true,
				statusCode: 200,
				message: "Avatar updated.",
				data: Auth.Response.Profile(user: .mock)
			)
			return response.toJSONData()
		case .deleteAvatar:
			let response = GeneralResponse(
				success: true,
				statusCode: 200,
				message: "Avatar removed.",
				data: Auth.Response.Profile(user: .mock)
			)
			return response.toJSONData()
		}
	}
}
