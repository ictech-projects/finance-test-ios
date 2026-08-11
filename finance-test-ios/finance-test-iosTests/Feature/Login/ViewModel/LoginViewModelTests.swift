//
//  LoginViewModelTests.swift
//  finance-test-iosTests
//

import Combine
import Foundation
import Testing
@testable import finance_test_ios

@Suite("LoginViewModel")
@MainActor
final class LoginViewModelTests: MemoryLeakTrackingSuite {

	// MARK: - Validation

	@Test
	func login_withEmptyEmail_setsEmailErrorAndSkipsRepositoryCall() async {
		let repository = AuthMockRepository()
		let sut = makeSUT(authRepository: repository)
		sut.email = ""
		sut.password = "password123"

		await sut.login()

		#expect(sut.emailErrorMessage == "Please enter your email.")
		#expect(sut.viewState == .error)
		#expect(repository.invocations.isEmpty)
	}

	@Test
	func login_withInvalidEmailFormat_setsEmailErrorAndSkipsRepositoryCall() async {
		let repository = AuthMockRepository()
		let sut = makeSUT(authRepository: repository)
		sut.email = "not-an-email"
		sut.password = "password123"

		await sut.login()

		#expect(sut.emailErrorMessage == "Please enter a valid email address.")
		#expect(sut.viewState == .error)
		#expect(repository.invocations.isEmpty)
	}

	@Test
	func login_withEmptyPassword_setsPasswordErrorAndSkipsRepositoryCall() async {
		let repository = AuthMockRepository()
		let sut = makeSUT(authRepository: repository)
		sut.email = "jane.doe@example.com"
		sut.password = ""

		await sut.login()

		#expect(sut.passwordErrorMessage == "Please enter your password.")
		#expect(sut.viewState == .error)
		#expect(repository.invocations.isEmpty)
	}

	// MARK: - Success

	@Test
	func login_success_setsIsLoggedInAndResetsViewState() async {
		let session = anySession()
		let repository = AuthMockRepository(loginResult: .loaded(anySessionSuccessResponse(session: session)))
		let sut = makeSUT(authRepository: repository)
		sut.email = "jane.doe@example.com"
		sut.password = "password123"

		await sut.login()

		#expect(repository.invocations == [
			.login(Auth.Request.Login(email: "jane.doe@example.com", password: "password123"))
		])
		#expect(sut.isLoggedIn == true)
		#expect(sut.viewState == .initial)
		#expect(sut.emailErrorMessage == nil)
		#expect(sut.passwordErrorMessage == nil)
	}

	@Test
	func login_success_emitsLoadingThenInitialViewState() async {
		let repository = AuthMockRepository(loginResult: .loaded(anySessionSuccessResponse()))
		let sut = makeSUT(authRepository: repository)
		sut.email = "jane.doe@example.com"
		sut.password = "password123"
		var receivedStates = [LoginViewModel.ViewState]()

		await confirmation("viewState transitions to loading then initial", expectedCount: 2) { confirm in
			let cancellable = sut.$viewState
				.dropFirst()
				.sink { state in
					receivedStates.append(state)
					confirm()
				}

			await sut.login()

			cancellable.cancel()
		}

		#expect(receivedStates == [.loading, .initial])
	}

	// MARK: - Backend errors

	@Test
	func login_whenErrorResponseHasFieldErrors_setsFieldSpecificMessages() async {
		let errorResponse = ErrorResponse(
			success: false,
			statusCode: 422,
			message: "Validation failed",
			errors: anyErrorField(
				email: ["The email field is invalid."],
				password: ["The password field is required."]
			)
		)
		let repository = AuthMockRepository(loginResult: .error(errorResponse))
		let sut = makeSUT(authRepository: repository)
		sut.email = "jane.doe@example.com"
		sut.password = "password123"

		await sut.login()

		#expect(sut.emailErrorMessage == "The email field is invalid.")
		#expect(sut.passwordErrorMessage == "The password field is required.")
		#expect(sut.generalErrorMessage == nil)
		#expect(sut.viewState == .error)
		#expect(sut.isLoggedIn == false)
	}

	@Test
	func login_whenErrorResponseHasOnlyEmailFieldError_leavesPasswordErrorNil() async {
		let errorResponse = ErrorResponse(
			success: false,
			statusCode: 422,
			message: "Validation failed",
			errors: anyErrorField(email: ["The email field is invalid."])
		)
		let repository = AuthMockRepository(loginResult: .error(errorResponse))
		let sut = makeSUT(authRepository: repository)
		sut.email = "jane.doe@example.com"
		sut.password = "password123"

		await sut.login()

		#expect(sut.emailErrorMessage == "The email field is invalid.")
		#expect(sut.passwordErrorMessage == nil)
		#expect(sut.generalErrorMessage == nil)
	}

	@Test
	func login_whenErrorResponseHasNoFieldErrors_setsGeneralErrorToBackendMessage() async {
		let errorResponse = ErrorResponse(
			success: false,
			statusCode: 401,
			message: "Invalid credentials.",
			errors: nil
		)
		let repository = AuthMockRepository(loginResult: .error(errorResponse))
		let sut = makeSUT(authRepository: repository)
		sut.email = "jane.doe@example.com"
		sut.password = "password123"

		await sut.login()

		#expect(sut.emailErrorMessage == nil)
		#expect(sut.passwordErrorMessage == nil)
		#expect(sut.generalErrorMessage == "Invalid credentials.")
		#expect(sut.viewState == .error)
		#expect(sut.isLoggedIn == false)
	}

	@Test
	func login_whenGenericError_setsGenericGeneralError() async {
		let repository = AuthMockRepository(loginResult: .error(NSError(domain: "TestError", code: 999)))
		let sut = makeSUT(authRepository: repository)
		sut.email = "jane.doe@example.com"
		sut.password = "password123"

		await sut.login()

		#expect(sut.emailErrorMessage == nil)
		#expect(sut.passwordErrorMessage == nil)
		#expect(sut.generalErrorMessage == "Something went wrong. Please try again.")
		#expect(sut.viewState == .error)
		#expect(sut.isLoggedIn == false)
	}

	// MARK: - Error clearing

	@Test
	func emailDidChange_whenErrorPresent_clearsEmailError() async {
		let repository = AuthMockRepository()
		let sut = makeSUT(authRepository: repository)
		sut.email = ""
		sut.password = "password123"
		await sut.login()
		#expect(sut.emailErrorMessage != nil)

		sut.emailDidChange()

		#expect(sut.emailErrorMessage == nil)
	}

	@Test
	func passwordDidChange_whenErrorPresent_clearsPasswordError() async {
		let repository = AuthMockRepository()
		let sut = makeSUT(authRepository: repository)
		sut.email = "jane.doe@example.com"
		sut.password = ""
		await sut.login()
		#expect(sut.passwordErrorMessage != nil)

		sut.passwordDidChange()

		#expect(sut.passwordErrorMessage == nil)
	}

	@Test
	func emailDidChange_whenGeneralErrorPresent_clearsGeneralError() async {
		let errorResponse = ErrorResponse(success: false, statusCode: 401, message: "Invalid credentials.", errors: nil)
		let repository = AuthMockRepository(loginResult: .error(errorResponse))
		let sut = makeSUT(authRepository: repository)
		sut.email = "jane.doe@example.com"
		sut.password = "password123"
		await sut.login()
		#expect(sut.generalErrorMessage != nil)

		sut.emailDidChange()

		#expect(sut.generalErrorMessage == nil)
	}

	@Test
	func passwordDidChange_whenGeneralErrorPresent_clearsGeneralError() async {
		let errorResponse = ErrorResponse(success: false, statusCode: 401, message: "Invalid credentials.", errors: nil)
		let repository = AuthMockRepository(loginResult: .error(errorResponse))
		let sut = makeSUT(authRepository: repository)
		sut.email = "jane.doe@example.com"
		sut.password = "password123"
		await sut.login()
		#expect(sut.generalErrorMessage != nil)

		sut.passwordDidChange()

		#expect(sut.generalErrorMessage == nil)
	}

	@Test
	func dismissGeneralError_clearsMessageAndResetsErrorViewState() async {
		let errorResponse = ErrorResponse(success: false, statusCode: 401, message: "Invalid credentials.", errors: nil)
		let repository = AuthMockRepository(loginResult: .error(errorResponse))
		let sut = makeSUT(authRepository: repository)
		sut.email = "jane.doe@example.com"
		sut.password = "password123"
		await sut.login()
		#expect(sut.generalErrorMessage != nil)
		#expect(sut.viewState == .error)

		sut.dismissGeneralError()

		#expect(sut.generalErrorMessage == nil)
		#expect(sut.viewState == .initial)
	}

	@Test
	func dismissGeneralError_whenNoErrorPresent_doesNothing() {
		let sut = makeSUT()

		sut.dismissGeneralError()

		#expect(sut.generalErrorMessage == nil)
		#expect(sut.viewState == .initial)
	}

	// MARK: - Synchronous helpers

	@Test
	func togglePasswordVisibility_flipsIsPasswordVisible() {
		let sut = makeSUT()
		#expect(sut.isPasswordVisible == false)

		sut.togglePasswordVisibility()
		#expect(sut.isPasswordVisible == true)

		sut.togglePasswordVisibility()
		#expect(sut.isPasswordVisible == false)
	}

	@Test
	func isSubmitDisabled_whenEmailOrPasswordEmpty_returnsTrue() {
		let sut = makeSUT()

		sut.email = ""
		sut.password = ""
		#expect(sut.isSubmitDisabled == true)

		sut.email = "jane.doe@example.com"
		sut.password = ""
		#expect(sut.isSubmitDisabled == true)

		sut.email = ""
		sut.password = "password123"
		#expect(sut.isSubmitDisabled == true)
	}

	@Test
	func isSubmitDisabled_whenEmailAndPasswordFilled_returnsFalse() {
		let sut = makeSUT()

		sut.email = "jane.doe@example.com"
		sut.password = "password123"

		#expect(sut.isSubmitDisabled == false)
	}

	// MARK: - Helpers

	private func makeSUT(
		authRepository: AuthMockRepository = AuthMockRepository(),
		file: StaticString = #filePath,
		line: UInt = #line
	) -> LoginViewModel {
		let sut = LoginViewModel(authRepository: authRepository)
		trackForMemoryLeak(sut, file: file, line: line)
		return sut
	}
}
