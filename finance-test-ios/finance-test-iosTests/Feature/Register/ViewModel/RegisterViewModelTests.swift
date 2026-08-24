//
//  RegisterViewModelTests.swift
//  finance-test-iosTests
//

import Combine
import Foundation
import Testing
@testable import finance_test_ios

@Suite("RegisterViewModel")
@MainActor
final class RegisterViewModelTests: MemoryLeakTrackingSuite {

	// MARK: - Validation

	@Test
	func register_withEmptyFullName_setsFullNameErrorAndSkipsRepositoryCall() async {
		let repository = AuthMockRepository()
		let sut = makeSUT(authRepository: repository)
		sut.fullName = ""
		sut.email = "jane.doe@example.com"
		sut.password = "password123"
		sut.confirmPassword = "password123"
		sut.isAgreedToTerms = true

		await sut.register()

		#expect(sut.fullNameErrorMessage == "Please enter your full name.")
		#expect(sut.viewState == .error)
		#expect(repository.invocations.isEmpty)
	}

	@Test
	func register_withEmptyEmail_setsEmailErrorAndSkipsRepositoryCall() async {
		let repository = AuthMockRepository()
		let sut = makeSUT(authRepository: repository)
		sut.fullName = "Jane Doe"
		sut.email = ""
		sut.password = "password123"
		sut.confirmPassword = "password123"
		sut.isAgreedToTerms = true

		await sut.register()

		#expect(sut.emailErrorMessage == "Please enter your email.")
		#expect(sut.viewState == .error)
		#expect(repository.invocations.isEmpty)
	}

	@Test
	func register_withInvalidEmailFormat_setsEmailErrorAndSkipsRepositoryCall() async {
		let repository = AuthMockRepository()
		let sut = makeSUT(authRepository: repository)
		sut.fullName = "Jane Doe"
		sut.email = "not-an-email"
		sut.password = "password123"
		sut.confirmPassword = "password123"
		sut.isAgreedToTerms = true

		await sut.register()

		#expect(sut.emailErrorMessage == "Please enter a valid email address.")
		#expect(repository.invocations.isEmpty)
	}

	@Test
	func register_withEmptyPassword_setsPasswordErrorAndSkipsRepositoryCall() async {
		let repository = AuthMockRepository()
		let sut = makeSUT(authRepository: repository)
		sut.fullName = "Jane Doe"
		sut.email = "jane.doe@example.com"
		sut.password = ""
		sut.confirmPassword = ""
		sut.isAgreedToTerms = true

		await sut.register()

		#expect(sut.passwordErrorMessage == "Please enter your password.")
		#expect(repository.invocations.isEmpty)
	}

	@Test
	func register_withMismatchedPasswords_setsConfirmPasswordErrorAndSkipsRepositoryCall() async {
		let repository = AuthMockRepository()
		let sut = makeSUT(authRepository: repository)
		sut.fullName = "Jane Doe"
		sut.email = "jane.doe@example.com"
		sut.password = "password123"
		sut.confirmPassword = "different456"
		sut.isAgreedToTerms = true

		await sut.register()

		#expect(sut.confirmPasswordErrorMessage == "Passwords do not match.")
		#expect(repository.invocations.isEmpty)
	}

	@Test
	func register_withoutAgreeingToTerms_setsTermsErrorAndSkipsRepositoryCall() async {
		let repository = AuthMockRepository()
		let sut = makeSUT(authRepository: repository)
		sut.fullName = "Jane Doe"
		sut.email = "jane.doe@example.com"
		sut.password = "password123"
		sut.confirmPassword = "password123"
		sut.isAgreedToTerms = false

		await sut.register()

		#expect(sut.termsErrorMessage == "Please agree to the Terms & Conditions and Privacy Policy to continue.")
		#expect(repository.invocations.isEmpty)
	}

	// MARK: - Success

	@Test
	func register_success_setsIsRegisteredAndResetsViewState() async {
		let session = anySession()
		let repository = AuthMockRepository(registerResult: .loaded(anySessionSuccessResponse(session: session)))
		let sut = makeSUT(authRepository: repository)
		sut.fullName = "Jane Doe"
		sut.email = "jane.doe@example.com"
		sut.password = "password123"
		sut.confirmPassword = "password123"
		sut.isAgreedToTerms = true

		await sut.register()

		#expect(repository.invocations == [
			.register(Auth.Request.Register(
				name: "Jane Doe",
				email: "jane.doe@example.com",
				password: "password123",
				passwordConfirmation: "password123"
			))
		])
		#expect(sut.isRegistered == true)
		#expect(sut.viewState == .initial)
		#expect(sut.fullNameErrorMessage == nil)
		#expect(sut.emailErrorMessage == nil)
		#expect(sut.passwordErrorMessage == nil)
		#expect(sut.confirmPasswordErrorMessage == nil)
	}

	@Test
	func register_success_emitsLoadingThenInitialViewState() async {
		let repository = AuthMockRepository(registerResult: .loaded(anySessionSuccessResponse()))
		let sut = makeSUT(authRepository: repository)
		sut.fullName = "Jane Doe"
		sut.email = "jane.doe@example.com"
		sut.password = "password123"
		sut.confirmPassword = "password123"
		sut.isAgreedToTerms = true
		var receivedStates = [RegisterViewModel.ViewState]()

		await confirmation("viewState transitions to loading then initial", expectedCount: 2) { confirm in
			let cancellable = sut.$viewState
				.dropFirst()
				.sink { state in
					receivedStates.append(state)
					confirm()
				}

			await sut.register()

			cancellable.cancel()
		}

		#expect(receivedStates == [.loading, .initial])
	}

	// MARK: - Backend errors

	@Test
	func register_whenErrorResponseHasFieldErrors_setsFieldSpecificMessages() async {
		let errorResponse = ErrorResponse(
			success: false,
			statusCode: 422,
			message: "Validation failed",
			errors: anyErrorField(
				email: ["The email has already been taken."],
				password: ["The password field must be at least 8 characters."],
				name: ["The name field is required."],
				passwordConfirmation: ["The password confirmation does not match."]
			)
		)
		let repository = AuthMockRepository(registerResult: .error(errorResponse))
		let sut = makeSUT(authRepository: repository)
		sut.fullName = "Jane Doe"
		sut.email = "jane.doe@example.com"
		sut.password = "password123"
		sut.confirmPassword = "password123"
		sut.isAgreedToTerms = true

		await sut.register()

		#expect(sut.fullNameErrorMessage == "The name field is required.")
		#expect(sut.emailErrorMessage == "The email has already been taken.")
		#expect(sut.passwordErrorMessage == "The password field must be at least 8 characters.")
		#expect(sut.confirmPasswordErrorMessage == "The password confirmation does not match.")
		#expect(sut.generalErrorMessage == nil)
		#expect(sut.viewState == .error)
		#expect(sut.isRegistered == false)
	}

	@Test
	func register_whenErrorResponseHasOnlyEmailFieldError_leavesOtherFieldErrorsNil() async {
		let errorResponse = ErrorResponse(
			success: false,
			statusCode: 422,
			message: "Validation failed",
			errors: anyErrorField(email: ["The email has already been taken."])
		)
		let repository = AuthMockRepository(registerResult: .error(errorResponse))
		let sut = makeSUT(authRepository: repository)
		sut.fullName = "Jane Doe"
		sut.email = "jane.doe@example.com"
		sut.password = "password123"
		sut.confirmPassword = "password123"
		sut.isAgreedToTerms = true

		await sut.register()

		#expect(sut.emailErrorMessage == "The email has already been taken.")
		#expect(sut.fullNameErrorMessage == nil)
		#expect(sut.passwordErrorMessage == nil)
		#expect(sut.confirmPasswordErrorMessage == nil)
		#expect(sut.generalErrorMessage == nil)
	}

	@Test
	func register_whenErrorResponseHasNoFieldErrors_setsGeneralErrorToBackendMessage() async {
		let errorResponse = ErrorResponse(
			success: false,
			statusCode: 500,
			message: "Unable to create your account. Please try again.",
			errors: nil
		)
		let repository = AuthMockRepository(registerResult: .error(errorResponse))
		let sut = makeSUT(authRepository: repository)
		sut.fullName = "Jane Doe"
		sut.email = "jane.doe@example.com"
		sut.password = "password123"
		sut.confirmPassword = "password123"
		sut.isAgreedToTerms = true

		await sut.register()

		#expect(sut.fullNameErrorMessage == nil)
		#expect(sut.emailErrorMessage == nil)
		#expect(sut.passwordErrorMessage == nil)
		#expect(sut.confirmPasswordErrorMessage == nil)
		#expect(sut.generalErrorMessage == "Unable to create your account. Please try again.")
		#expect(sut.viewState == .error)
		#expect(sut.isRegistered == false)
	}

	@Test
	func register_whenGenericError_setsGenericGeneralError() async {
		let repository = AuthMockRepository(registerResult: .error(NSError(domain: "TestError", code: 999)))
		let sut = makeSUT(authRepository: repository)
		sut.fullName = "Jane Doe"
		sut.email = "jane.doe@example.com"
		sut.password = "password123"
		sut.confirmPassword = "password123"
		sut.isAgreedToTerms = true

		await sut.register()

		#expect(sut.generalErrorMessage == "Something went wrong. Please try again.")
		#expect(sut.viewState == .error)
		#expect(sut.isRegistered == false)
	}

	// MARK: - Error clearing

	@Test
	func fullNameDidChange_whenErrorPresent_clearsFullNameError() async {
		let repository = AuthMockRepository()
		let sut = makeSUT(authRepository: repository)
		sut.fullName = ""
		sut.isAgreedToTerms = true
		await sut.register()
		#expect(sut.fullNameErrorMessage != nil)

		sut.fullNameDidChange()

		#expect(sut.fullNameErrorMessage == nil)
	}

	@Test
	func emailDidChange_whenErrorPresent_clearsEmailError() async {
		let repository = AuthMockRepository()
		let sut = makeSUT(authRepository: repository)
		sut.fullName = "Jane Doe"
		sut.email = ""
		sut.isAgreedToTerms = true
		await sut.register()
		#expect(sut.emailErrorMessage != nil)

		sut.emailDidChange()

		#expect(sut.emailErrorMessage == nil)
	}

	@Test
	func passwordDidChange_whenErrorPresent_clearsPasswordError() async {
		let repository = AuthMockRepository()
		let sut = makeSUT(authRepository: repository)
		sut.fullName = "Jane Doe"
		sut.email = "jane.doe@example.com"
		sut.password = ""
		sut.isAgreedToTerms = true
		await sut.register()
		#expect(sut.passwordErrorMessage != nil)

		sut.passwordDidChange()

		#expect(sut.passwordErrorMessage == nil)
	}

	@Test
	func confirmPasswordDidChange_whenErrorPresent_clearsConfirmPasswordError() async {
		let repository = AuthMockRepository()
		let sut = makeSUT(authRepository: repository)
		sut.fullName = "Jane Doe"
		sut.email = "jane.doe@example.com"
		sut.password = "password123"
		sut.confirmPassword = "different456"
		sut.isAgreedToTerms = true
		await sut.register()
		#expect(sut.confirmPasswordErrorMessage != nil)

		sut.confirmPasswordDidChange()

		#expect(sut.confirmPasswordErrorMessage == nil)
	}

	@Test
	func toggleAgreedToTerms_whenErrorPresentAndNowAgreed_clearsTermsError() async {
		let repository = AuthMockRepository()
		let sut = makeSUT(authRepository: repository)
		sut.fullName = "Jane Doe"
		sut.email = "jane.doe@example.com"
		sut.password = "password123"
		sut.confirmPassword = "password123"
		sut.isAgreedToTerms = false
		await sut.register()
		#expect(sut.termsErrorMessage != nil)

		sut.toggleAgreedToTerms()

		#expect(sut.isAgreedToTerms == true)
		#expect(sut.termsErrorMessage == nil)
	}

	@Test
	func emailDidChange_whenGeneralErrorPresent_clearsGeneralError() async {
		let errorResponse = ErrorResponse(success: false, statusCode: 500, message: "Server error.", errors: nil)
		let repository = AuthMockRepository(registerResult: .error(errorResponse))
		let sut = makeSUT(authRepository: repository)
		sut.fullName = "Jane Doe"
		sut.email = "jane.doe@example.com"
		sut.password = "password123"
		sut.confirmPassword = "password123"
		sut.isAgreedToTerms = true
		await sut.register()
		#expect(sut.generalErrorMessage != nil)

		sut.emailDidChange()

		#expect(sut.generalErrorMessage == nil)
	}

	@Test
	func dismissGeneralError_clearsMessageAndResetsErrorViewState() async {
		let errorResponse = ErrorResponse(success: false, statusCode: 500, message: "Server error.", errors: nil)
		let repository = AuthMockRepository(registerResult: .error(errorResponse))
		let sut = makeSUT(authRepository: repository)
		sut.fullName = "Jane Doe"
		sut.email = "jane.doe@example.com"
		sut.password = "password123"
		sut.confirmPassword = "password123"
		sut.isAgreedToTerms = true
		await sut.register()
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
	func toggleAgreedToTerms_flipsIsAgreedToTerms() {
		let sut = makeSUT()
		#expect(sut.isAgreedToTerms == false)

		sut.toggleAgreedToTerms()
		#expect(sut.isAgreedToTerms == true)

		sut.toggleAgreedToTerms()
		#expect(sut.isAgreedToTerms == false)
	}

	@Test
	func isSubmitDisabled_whenAnyRequiredFieldEmpty_returnsTrue() {
		let sut = makeSUT()

		sut.fullName = ""
		sut.email = "jane.doe@example.com"
		sut.password = "password123"
		sut.confirmPassword = "password123"
		#expect(sut.isSubmitDisabled == true)

		sut.fullName = "Jane Doe"
		sut.email = ""
		#expect(sut.isSubmitDisabled == true)
	}

	@Test
	func isSubmitDisabled_whenAllRequiredFieldsFilled_returnsFalse() {
		let sut = makeSUT()

		sut.fullName = "Jane Doe"
		sut.email = "jane.doe@example.com"
		sut.password = "password123"
		sut.confirmPassword = "password123"

		#expect(sut.isSubmitDisabled == false)
	}

	// MARK: - Helpers

	private func makeSUT(
		authRepository: AuthMockRepository = AuthMockRepository(),
		file: StaticString = #filePath,
		line: UInt = #line
	) -> RegisterViewModel {
		let sut = RegisterViewModel(authRepository: authRepository)
		trackForMemoryLeak(sut, file: file, line: line)
		return sut
	}
}
