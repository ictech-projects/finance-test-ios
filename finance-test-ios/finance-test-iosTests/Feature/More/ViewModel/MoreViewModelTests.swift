//
//  MoreViewModelTests.swift
//  finance-test-iosTests
//

import Testing
@testable import finance_test_ios

@Suite("MoreViewModel")
@MainActor
final class MoreViewModelTests: MemoryLeakTrackingSuite {

	// MARK: - onLoad

	@Test
	func onLoad_success_setsProfileAndLoadedState() async {
		let user = anyUser(name: "Alex Thompson", email: "alex.t@financialarchitect.com")
		let repository = AuthMockRepository(getProfileResult: .loaded(anyProfileSuccessResponse(user: user)))
		let sut = makeSUT(authRepository: repository)

		await sut.onLoad()

		#expect(sut.viewState == .loaded)
		#expect(sut.profile == user)
	}

	@Test
	func onLoad_error_setsErrorState() async {
		let errorResponse = ErrorResponse(success: false, statusCode: 500, message: "Request failed", errors: nil)
		let repository = AuthMockRepository(getProfileResult: .error(errorResponse))
		let sut = makeSUT(authRepository: repository)

		await sut.onLoad()

		#expect(sut.viewState == .error)
		#expect(sut.profile == nil)
	}

	// MARK: - logOutTapped

	@Test
	func logOutTapped_callsRepositoryLogout() async {
		let repository = AuthMockRepository(logoutResult: .loaded(anyEmptySuccessResponse()))
		let sut = makeSUT(authRepository: repository)

		await sut.logOutTapped()

		#expect(repository.invocations == [.logout])
	}

	@Test
	func logOutTapped_onRepositorySuccess_flipsSessionStoreIsLoggedInFalse() async {
		let repository = AuthMockRepository(logoutResult: .loaded(anyEmptySuccessResponse()))
		let sessionStore = SessionStore(localDataSource: AuthMockLocalDataSource(accessToken: "token"))
		let sut = makeSUT(authRepository: repository, sessionStore: sessionStore)
		#expect(sessionStore.isLoggedIn == true)

		await sut.logOutTapped()

		#expect(sessionStore.isLoggedIn == false)
	}

	@Test
	func logOutTapped_onRepositoryFailure_stillFlipsSessionStoreIsLoggedInFalse() async {
		let errorResponse = ErrorResponse(success: false, statusCode: 500, message: "Logout failed", errors: nil)
		let repository = AuthMockRepository(logoutResult: .error(errorResponse))
		let sessionStore = SessionStore(localDataSource: AuthMockLocalDataSource(accessToken: "token"))
		let sut = makeSUT(authRepository: repository, sessionStore: sessionStore)
		#expect(sessionStore.isLoggedIn == true)

		await sut.logOutTapped()

		#expect(sessionStore.isLoggedIn == false)
	}

	@Test
	func logOutTapped_setsIsLoggingOutDuringCallThenResetsAfter() async {
		let repository = AuthMockRepository(logoutResult: .loaded(anyEmptySuccessResponse()))
		let sut = makeSUT(authRepository: repository)
		#expect(sut.isLoggingOut == false)

		await sut.logOutTapped()

		#expect(sut.isLoggingOut == false)
	}

	// MARK: - Helpers

	private func makeSUT(
		authRepository: AuthMockRepository = AuthMockRepository(),
		sessionStore: SessionStore? = nil,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> MoreViewModel {
		let sessionStore = sessionStore ?? SessionStore(localDataSource: AuthMockLocalDataSource())
		let sut = MoreViewModel(authRepository: authRepository, sessionStore: sessionStore)
		trackForMemoryLeak(sut, file: file, line: line)
		return sut
	}
}
