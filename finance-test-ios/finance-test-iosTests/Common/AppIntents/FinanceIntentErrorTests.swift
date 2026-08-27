//
//  FinanceIntentErrorTests.swift
//  finance-test-iosTests
//

import Foundation
import Testing
@testable import finance_test_ios

@Suite("FinanceIntentError")
struct FinanceIntentErrorTests {

	@Test
	func from_whenErrorResponseIs401_returnsSessionExpired() {
		let errorResponse = ErrorResponse(success: false, statusCode: 401, message: "Unauthenticated.", errors: nil)

		let result = FinanceIntentError.from(errorResponse)

		#expect(result == .sessionExpired)
	}

	@Test(arguments: [422, 500])
	func from_whenErrorResponseIsNot401_returnsRequestFailedWithBackendMessage(statusCode: Int) {
		let errorResponse = ErrorResponse(success: false, statusCode: statusCode, message: "Something specific broke.", errors: nil)

		let result = FinanceIntentError.from(errorResponse)

		#expect(result == .requestFailed(message: "Something specific broke."))
	}

	@Test
	func from_whenErrorResponseHasNoMessage_returnsRequestFailedWithGenericMessage() {
		let errorResponse = ErrorResponse(success: false, statusCode: 500, message: nil, errors: nil)

		let result = FinanceIntentError.from(errorResponse)

		#expect(result == .requestFailed(message: "Something went wrong. Please try again."))
	}

	@Test
	func from_whenGenericError_returnsRequestFailedWithGenericMessage() {
		let result = FinanceIntentError.from(NSError(domain: "TestError", code: 1))

		#expect(result == .requestFailed(message: "Something went wrong. Please try again."))
	}
}
