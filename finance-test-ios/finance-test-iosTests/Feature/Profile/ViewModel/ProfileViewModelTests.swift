//
//  ProfileViewModelTests.swift
//  finance-test-iosTests
//

import Foundation
import Testing
@testable import finance_test_ios

@Suite("ProfileViewModel")
@MainActor
final class ProfileViewModelTests: MemoryLeakTrackingSuite {

	// MARK: - saveName validation

	@Test
	func saveName_withEmptyName_setsErrorAndSkipsRepositoryCall() async {
		let repository = AuthMockRepository()
		let sut = makeSUT(authRepository: repository)
		sut.name = "   "

		await sut.saveName()

		#expect(sut.errorMessage == "Please enter your name.")
		#expect(sut.isErrorPresented == true)
		#expect(repository.invocations.isEmpty)
	}

	// MARK: - saveName success

	@Test
	func saveName_success_updatesUserAndResetsViewState() async {
		let updatedUser = anyUser(name: "Jane Smith")
		let repository = AuthMockRepository(
			updateProfileResult: .loaded(anyProfileSuccessResponse(user: updatedUser))
		)
		let sut = makeSUT(user: anyUser(name: "Jane Doe"), authRepository: repository)
		sut.name = "Jane Smith"

		await sut.saveName()

		#expect(repository.invocations == [.updateProfile(Auth.Request.UpdateProfile(name: "Jane Smith"))])
		#expect(sut.user == updatedUser)
		#expect(sut.name == "Jane Smith")
		#expect(sut.viewState == .idle)
		#expect(sut.isErrorPresented == false)
	}

	// MARK: - saveName errors

	@Test
	func saveName_whenBackendError_setsErrorMessageFromResponse() async {
		let errorResponse = ErrorResponse(success: false, statusCode: 422, message: "Name is invalid.", errors: nil)
		let repository = AuthMockRepository(updateProfileResult: .error(errorResponse))
		let sut = makeSUT(authRepository: repository)
		sut.name = "New Name"

		await sut.saveName()

		#expect(sut.errorMessage == "Name is invalid.")
		#expect(sut.isErrorPresented == true)
		#expect(sut.viewState == .idle)
	}

	@Test
	func saveName_whenGenericError_setsGenericErrorMessage() async {
		let repository = AuthMockRepository(updateProfileResult: .error(NSError(domain: "TestError", code: 1)))
		let sut = makeSUT(authRepository: repository)
		sut.name = "New Name"

		await sut.saveName()

		#expect(sut.errorMessage == "Something went wrong. Please try again.")
		#expect(sut.isErrorPresented == true)
	}

	// MARK: - uploadAvatar

	@Test
	func uploadAvatar_success_updatesUserAndResetsViewState() async {
		let updatedUser = anyUser()
		let repository = AuthMockRepository(uploadAvatarResult: .loaded(anyProfileSuccessResponse(user: updatedUser)))
		let sut = makeSUT(authRepository: repository)
		let imageData = Data([0x01, 0x02, 0x03])

		await sut.uploadAvatar(imageData: imageData, fileName: "avatar.jpg", mimeType: "image/jpeg")

		#expect(repository.invocations == [
			.uploadAvatar(imageData: imageData, fileName: "avatar.jpg", mimeType: "image/jpeg")
		])
		#expect(sut.user == updatedUser)
		#expect(sut.viewState == .idle)
	}

	@Test
	func uploadAvatar_whenBackendError_setsErrorMessage() async {
		let errorResponse = ErrorResponse(success: false, statusCode: 422, message: "Avatar is invalid.", errors: nil)
		let repository = AuthMockRepository(uploadAvatarResult: .error(errorResponse))
		let sut = makeSUT(authRepository: repository)

		await sut.uploadAvatar(imageData: Data([0x01]), fileName: "avatar.jpg", mimeType: "image/jpeg")

		#expect(sut.errorMessage == "Avatar is invalid.")
		#expect(sut.isErrorPresented == true)
		#expect(sut.viewState == .idle)
	}

	// MARK: - removeAvatar

	@Test
	func removeAvatar_success_updatesUserAndResetsViewState() async {
		let updatedUser = anyUser()
		let repository = AuthMockRepository(deleteAvatarResult: .loaded(anyProfileSuccessResponse(user: updatedUser)))
		let sut = makeSUT(authRepository: repository)

		await sut.removeAvatar()

		#expect(repository.invocations == [.deleteAvatar])
		#expect(sut.user == updatedUser)
		#expect(sut.viewState == .idle)
	}

	@Test
	func removeAvatar_whenBackendError_setsErrorMessage() async {
		let errorResponse = ErrorResponse(success: false, statusCode: 500, message: "Couldn't remove avatar.", errors: nil)
		let repository = AuthMockRepository(deleteAvatarResult: .error(errorResponse))
		let sut = makeSUT(authRepository: repository)

		await sut.removeAvatar()

		#expect(sut.errorMessage == "Couldn't remove avatar.")
		#expect(sut.isErrorPresented == true)
	}

	// MARK: - isSaveDisabled

	@Test
	func isSaveDisabled_whenNameUnchangedOrEmpty_returnsTrue() {
		let sut = makeSUT(user: anyUser(name: "Jane Doe"))
		#expect(sut.isSaveDisabled == true)

		sut.name = "   "
		#expect(sut.isSaveDisabled == true)
	}

	@Test
	func isSaveDisabled_whenNameChanged_returnsFalse() {
		let sut = makeSUT(user: anyUser(name: "Jane Doe"))

		sut.name = "Jane Smith"

		#expect(sut.isSaveDisabled == false)
	}

	// MARK: - Helpers

	private func makeSUT(
		user: Auth.Response.User = anyUser(),
		authRepository: AuthMockRepository = AuthMockRepository(),
		file: StaticString = #filePath,
		line: UInt = #line
	) -> ProfileViewModel {
		let sut = ProfileViewModel(user: user, authRepository: authRepository)
		trackForMemoryLeak(sut, file: file, line: line)
		return sut
	}
}
