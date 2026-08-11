//
//  Moya+UnauthorizedResponsePlugin.swift
//  finance-test-ios
//

import Foundation
import Moya

/// Forces app-wide logout on any 401 response from an endpoint that required authorization.
/// A pure side-effecting pass-through: always returns `result` unchanged, so the existing
/// decode/`ErrorResponse` handling in `Moya+Request.swift`/`Moya+RequestCombine.swift` at every
/// call site is unaffected.
final class UnauthorizedResponsePlugin: PluginType {

	private let onUnauthorized: () -> Void

	// `Task` here must be `_Concurrency.Task`, fully qualified — Moya's own `Moya.Task` (the
	// request-task enum) shadows Swift Concurrency's `Task` in any file that `import Moya`.
	init(onUnauthorized: @escaping () -> Void = { _Concurrency.Task { @MainActor in SessionStore.shared.forceLogout() } }) {
		self.onUnauthorized = onUnauthorized
	}

	func process(
		_ result: Result<Moya.Response, MoyaError>,
		target: TargetType
	) -> Result<Moya.Response, MoyaError> {
		if
			case .success(let response) = result,
			response.statusCode == 401,
			let authorizable = target as? AccessTokenAuthorizable,
			authorizable.authorizationType != nil
		{
			onUnauthorized()
		}
		return result
	}
}
