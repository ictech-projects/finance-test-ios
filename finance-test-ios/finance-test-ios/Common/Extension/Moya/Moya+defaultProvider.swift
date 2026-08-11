//
//  Moya+defaultProvider.swift
//  HJK
//
//  Created by Ewide Dev 5 on 11/09/25.
//

import Foundation
import Moya

extension MoyaProvider {
    static func defaultProvider() -> MoyaProvider {
#if DEBUG
        return MoyaProvider(plugins: [NetworkLoggerPlugin(), BearerTokenPlugin(), UnauthorizedResponsePlugin()])
#else
		return MoyaProvider(plugins: [BearerTokenPlugin(), UnauthorizedResponsePlugin()])
#endif
    }
}

/// Attaches `Authorization: Bearer <token>` to every request, unconditionally — regardless of
/// whether the target actually needs it (harmless for the few unauthenticated endpoints, e.g.
/// login/register, since the backend ignores the header there).
///
/// Deliberately NOT using Moya's own `AccessTokenPlugin`: its `prepare()` internally does
/// `target as? AccessTokenAuthorizable`, and that cast reliably fails when invoked through
/// Alamofire's `RequestInterceptor.prepare(...)` closure path in this project's toolchain setup
/// (confirmed via a live-network test — the header was silently never attached, causing every
/// authenticated call, e.g. `/auth/profile`, to 401). The same cast pattern works fine elsewhere
/// (e.g. `UnauthorizedResponsePlugin.process(...)`, called directly by Moya without crossing
/// through an Alamofire interceptor closure), so this is scoped specifically to token attachment.
final class BearerTokenPlugin: PluginType {
	func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
		var request = request
		let token = KeychainHelper.shared.getString(for: KeychainKey.accessToken.key).orEmpty()
		request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		return request
	}
}
