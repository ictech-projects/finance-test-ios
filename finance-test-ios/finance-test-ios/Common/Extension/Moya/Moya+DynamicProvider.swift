//
//  Moya+DynamicProvider.swift
// IosBaseProject
//
//  Created by Arifin Firdaus on 12/12/25.
//

import Foundation
import Moya

extension MoyaProvider {
	static func dynamicProvider() -> MoyaProvider {
#if DEBUG
		return MoyaProvider(plugins: [NetworkLoggerPlugin(), DynamicTokenPlugin(), UnauthorizedResponsePlugin()])
#else
		return MoyaProvider(plugins: [DynamicTokenPlugin(), UnauthorizedResponsePlugin()])
#endif
	}
}

/// Currently unused (no call sites for `dynamicProvider()`). Note before wiring this up:
/// `target as? AccessTokenAuthorizable` below is unreliable when `prepare(...)` is invoked
/// through Alamofire's `RequestInterceptor` closure path — confirmed via a live-network test on
/// `.defaultProvider()`'s equivalent (`AccessTokenPlugin`), where the same cast pattern silently
/// failed for every request, never attaching the Authorization header. See `BearerTokenPlugin`
/// in `Moya+defaultProvider.swift` for the working alternative and full explanation.
final class DynamicTokenPlugin: PluginType {

	func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
		guard
			let authTarget = target as? AccessTokenAuthorizable,
			let type = authTarget.authorizationType
		else {
			return request
		}

		let keychain = KeychainHelper.shared

		let token: String =
			switch type {
			case .bearer:
				keychain.getString(for: KeychainKey.accessToken.key).orEmpty()
			case .custom(let string):
				if string == CustomAuthorizationTokenKey.tempToken {
					keychain.getString(for: KeychainKey.temporaryToken.key).orEmpty()
				} else {
					""
				}
			default:
				""
			}
		var req = request
		req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		return req
	}
}

enum CustomAuthorizationTokenKey {
	/// use this for change password
	static let tempToken = "temp_token"
}
