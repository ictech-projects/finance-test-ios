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
		let sessionStore = AuthMockSessionStore()
		let sut = makeSUT(sessionStore: sessionStore)
		#expect(sut.isLaunching == true)

		await sut.onAppear()

		#expect(sut.isLaunching == false)
		#expect(sessionStore.invocations == [.refreshFromKeychain])
	}

	@Test
	func init_reflectsSessionStoreInitialIsLoggedIn() {
		let sessionStore = AuthMockSessionStore(isLoggedIn: true)
		let sut = makeSUT(sessionStore: sessionStore)

		#expect(sut.isLoggedIn == true)
	}

	@Test
	func isLoggedIn_keepsTrackingSessionStoreAfterOnAppear() async {
		let sessionStore = AuthMockSessionStore(isLoggedIn: true)
		let sut = makeSUT(sessionStore: sessionStore)
		await sut.onAppear()
		#expect(sut.isLoggedIn == true)

		sessionStore.forceLogout()

		#expect(sut.isLoggedIn == false)
	}

	// MARK: - Helpers

	private func makeSUT(
		sessionStore: AuthMockSessionStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> LaunchScreenViewModel {
		let sut = LaunchScreenViewModel(sessionStore: sessionStore, minimumDisplayDuration: .zero)
		trackForMemoryLeak(sut, file: file, line: line)
		return sut
	}
}
