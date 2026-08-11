//
//  LaunchScreenViewModelTests.swift
//  finance-test-iosTests
//

import Testing
@testable import finance_test_ios

@Suite("LaunchScreenViewModel")
@MainActor
final class LaunchScreenViewModelTests: MemoryLeakTrackingSuite {

	@Test
	func onAppear_refreshesFromKeychainAndStopsLaunching() async {
		let sessionStore = SessionStore(localDataSource: AuthMockLocalDataSource())
		let sut = makeSUT(sessionStore: sessionStore)
		#expect(sut.isLaunching == true)

		await sut.onAppear()

		#expect(sut.isLaunching == false)
	}

	@Test
	func init_reflectsSessionStoreInitialIsLoggedIn() {
		let sessionStore = SessionStore(localDataSource: AuthMockLocalDataSource(accessToken: "token"))
		let sut = makeSUT(sessionStore: sessionStore)

		#expect(sut.isLoggedIn == true)
	}

	@Test
	func isLoggedIn_keepsTrackingSessionStoreAfterOnAppear() async {
		let sessionStore = SessionStore(localDataSource: AuthMockLocalDataSource(accessToken: "token"))
		let sut = makeSUT(sessionStore: sessionStore)
		await sut.onAppear()
		#expect(sut.isLoggedIn == true)

		sessionStore.forceLogout()

		#expect(sut.isLoggedIn == false)
	}

	// MARK: - Helpers

	private func makeSUT(
		sessionStore: SessionStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> LaunchScreenViewModel {
		let sut = LaunchScreenViewModel(sessionStore: sessionStore)
		trackForMemoryLeak(sut, file: file, line: line)
		return sut
	}
}
