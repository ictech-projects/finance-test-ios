//
//  UnauthorizedResponsePluginTests.swift
//  finance-test-iosTests
//

import Foundation
import Moya
import Testing
@testable import finance_test_ios

@Suite("UnauthorizedResponsePlugin")
struct UnauthorizedResponsePluginTests {

	@Test
	func process_on401ForBearerTarget_firesOnUnauthorized() async {
		await confirmation("onUnauthorized is called") { confirm in
			let sut = UnauthorizedResponsePlugin(onUnauthorized: { confirm() })

			_ = sut.process(.success(anyResponse(statusCode: 401)), target: AuthTargetType.getProfile)
		}
	}

	@Test
	func process_on401ForUnauthorizedTarget_doesNotFire() {
		var fired = false
		let sut = UnauthorizedResponsePlugin(onUnauthorized: { fired = true })

		_ = sut.process(.success(anyResponse(statusCode: 401)), target: AuthTargetType.login(anyLoginRequest()))

		#expect(fired == false)
	}

	@Test
	func process_on200ForBearerTarget_doesNotFire() {
		var fired = false
		let sut = UnauthorizedResponsePlugin(onUnauthorized: { fired = true })

		_ = sut.process(.success(anyResponse(statusCode: 200)), target: AuthTargetType.getProfile)

		#expect(fired == false)
	}

	@Test
	func process_onFailureResult_doesNotFire() {
		var fired = false
		let sut = UnauthorizedResponsePlugin(onUnauthorized: { fired = true })

		_ = sut.process(.failure(MoyaError.statusCode(anyResponse(statusCode: 401))), target: AuthTargetType.getProfile)

		#expect(fired == false)
	}

	@Test
	func process_alwaysReturnsResultUnchanged() {
		let sut = UnauthorizedResponsePlugin(onUnauthorized: {})
		let response = anyResponse(statusCode: 401)

		let result = sut.process(.success(response), target: AuthTargetType.getProfile)

		guard case .success(let returned) = result else {
			Issue.record("Expected .success")
			return
		}
		#expect(returned === response)
	}

	// MARK: - Helpers

	private func anyResponse(statusCode: Int) -> Moya.Response {
		Moya.Response(statusCode: statusCode, data: Data())
	}
}
