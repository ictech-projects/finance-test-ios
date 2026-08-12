//
//  AuthDefaultSessionStoreTests.swift
//  finance-test-iosTests
//

import Testing
@testable import finance_test_ios

@Suite("AuthDefaultSessionStore")
@MainActor
final class AuthDefaultSessionStoreTests: MemoryLeakTrackingSuite {

	@Test
	func init_whenAccessTokenPresent_isLoggedInTrue() {
		let sut = makeSUT(local: AuthMockLocalDataSource(accessToken: "token"))

		#expect(sut.isLoggedIn == true)
	}

	@Test
	func init_whenNoAccessToken_isLoggedInFalse() {
		let sut = makeSUT(local: AuthMockLocalDataSource())

		#expect(sut.isLoggedIn == false)
	}

	@Test
	func refreshFromKeychain_reReadsCurrentKeychainState() {
		let local = AuthMockLocalDataSource()
		let sut = makeSUT(local: local)
		#expect(sut.isLoggedIn == false)

		local.saveSession(accessToken: "token", refreshToken: "refresh")
		sut.refreshFromKeychain()

		#expect(sut.isLoggedIn == true)
	}

	@Test
	func markLoggedIn_setsIsLoggedInTrue() {
		let sut = makeSUT(local: AuthMockLocalDataSource())

		sut.markLoggedIn()

		#expect(sut.isLoggedIn == true)
	}

	@Test
	func forceLogout_clearsSessionAndSetsIsLoggedInFalse() {
		let local = AuthMockLocalDataSource(accessToken: "token", refreshToken: "refresh")
		let sut = makeSUT(local: local)

		sut.forceLogout()

		// `.getAccessToken` is from `init` computing the initial `isLoggedIn` value.
		#expect(local.invocations == [.getAccessToken, .clearSession])
		#expect(sut.isLoggedIn == false)
	}

	@Test
	func forceLogout_whenAlreadyLoggedOut_isNoOp() {
		let local = AuthMockLocalDataSource()
		let sut = makeSUT(local: local)

		sut.forceLogout()

		#expect(local.invocations == [.getAccessToken])
		#expect(sut.isLoggedIn == false)
	}

	// MARK: - Helpers

	private func makeSUT(
		local: AuthMockLocalDataSource,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> AuthDefaultSessionStore {
		let sut = AuthDefaultSessionStore(localDataSource: local)
		trackForMemoryLeak(sut, file: file, line: line)
		return sut
	}
}
