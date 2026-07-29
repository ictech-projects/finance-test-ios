//
//  AuthDefaultRepositoryTests.swift
//  finance-test-iosTests
//

import Foundation
import Testing
@testable import finance_test_ios

@Suite("AuthDefaultRepository")
struct AuthDefaultRepositoryTests {

	// MARK: - register

	@Test func register_callsRemoteWithCorrectRequest() async throws {
		let remote = AuthMockRemoteDataSource(registerResult: .success(anySessionSuccessResponse()))
		let sut = makeSUT(remote: remote)

		_ = try await sut.register(request: anyRegisterRequest())

		#expect(remote.invocations == [.register(anyRegisterRequest())])
	}

	@Test func register_success_returnsExpectedDataAndSavesSession() async throws {
		let session = anySession()
		let remote = AuthMockRemoteDataSource(registerResult: .success(anySessionSuccessResponse(session: session)))
		let local = AuthMockLocalDataSource()
		let sut = makeSUT(remote: remote, local: local)

		let result = try await sut.register(request: anyRegisterRequest())

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.data == session)
		#expect(local.invocations == [.saveSession(accessToken: session.token, refreshToken: session.refreshToken)])
	}

	@Test(arguments: [401, 422, 500])
	func register_whenThrowsErrorResponse_returnsErrorStateAndSkipsSave(statusCode: Int) async throws {
		let expectedError = ErrorResponse(success: false, statusCode: statusCode, message: "Registration failed", errors: nil)
		let remote = AuthMockRemoteDataSource(registerResult: .failure(expectedError))
		let local = AuthMockLocalDataSource()
		let sut = makeSUT(remote: remote, local: local)

		let result = try await sut.register(request: anyRegisterRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == statusCode)
		#expect(local.invocations.isEmpty)
	}

	@Test func register_whenThrowsGenericError_returnsErrorState() async throws {
		let dummyError = NSError(domain: "TestError", code: 999)
		let remote = AuthMockRemoteDataSource(registerResult: .failure(dummyError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.register(request: anyRegisterRequest())

		guard case .error(let error as NSError) = result else {
			Issue.record("Expected .error(NSError)")
			return
		}
		#expect(error.domain == "TestError")
		#expect(error.code == 999)
	}

	// MARK: - login

	@Test func login_callsRemoteWithCorrectRequest() async throws {
		let remote = AuthMockRemoteDataSource(loginResult: .success(anySessionSuccessResponse()))
		let sut = makeSUT(remote: remote)

		_ = try await sut.login(request: anyLoginRequest())

		#expect(remote.invocations == [.login(anyLoginRequest())])
	}

	@Test func login_success_returnsExpectedDataAndSavesSession() async throws {
		let session = anySession()
		let remote = AuthMockRemoteDataSource(loginResult: .success(anySessionSuccessResponse(session: session)))
		let local = AuthMockLocalDataSource()
		let sut = makeSUT(remote: remote, local: local)

		let result = try await sut.login(request: anyLoginRequest())

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.success == true)
		#expect(response.statusCode == 200)
		#expect(response.data == session)
		#expect(local.invocations == [.saveSession(accessToken: session.token, refreshToken: session.refreshToken)])
	}

	@Test(arguments: [401, 404, 500])
	func login_whenThrowsErrorResponse_returnsErrorStateAndSkipsSave(statusCode: Int) async throws {
		let expectedError = ErrorResponse(success: false, statusCode: statusCode, message: "Invalid credentials.", errors: nil)
		let remote = AuthMockRemoteDataSource(loginResult: .failure(expectedError))
		let local = AuthMockLocalDataSource()
		let sut = makeSUT(remote: remote, local: local)

		let result = try await sut.login(request: anyLoginRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == statusCode)
		#expect(error.message == "Invalid credentials.")
		#expect(local.invocations.isEmpty)
	}

	@Test func login_whenThrowsGenericError_returnsErrorState() async throws {
		let dummyError = NSError(domain: "TestError", code: 999)
		let remote = AuthMockRemoteDataSource(loginResult: .failure(dummyError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.login(request: anyLoginRequest())

		guard case .error(let error as NSError) = result else {
			Issue.record("Expected .error(NSError)")
			return
		}
		#expect(error.domain == "TestError")
		#expect(error.code == 999)
	}

	// MARK: - refresh

	@Test func refresh_callsRemoteWithCorrectRequest() async throws {
		let remote = AuthMockRemoteDataSource(refreshResult: .success(anySessionSuccessResponse()))
		let sut = makeSUT(remote: remote)

		_ = try await sut.refresh(request: anyRefreshRequest())

		#expect(remote.invocations == [.refresh(anyRefreshRequest())])
	}

	@Test func refresh_success_returnsExpectedDataAndSavesSession() async throws {
		let session = anySession()
		let remote = AuthMockRemoteDataSource(refreshResult: .success(anySessionSuccessResponse(session: session)))
		let local = AuthMockLocalDataSource()
		let sut = makeSUT(remote: remote, local: local)

		let result = try await sut.refresh(request: anyRefreshRequest())

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.data == session)
		#expect(local.invocations == [.saveSession(accessToken: session.token, refreshToken: session.refreshToken)])
	}

	@Test(arguments: [401, 404, 500])
	func refresh_whenThrowsErrorResponse_returnsErrorStateAndSkipsSave(statusCode: Int) async throws {
		let expectedError = ErrorResponse(success: false, statusCode: statusCode, message: "Refresh failed", errors: nil)
		let remote = AuthMockRemoteDataSource(refreshResult: .failure(expectedError))
		let local = AuthMockLocalDataSource()
		let sut = makeSUT(remote: remote, local: local)

		let result = try await sut.refresh(request: anyRefreshRequest())

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == statusCode)
		#expect(local.invocations.isEmpty)
	}

	@Test func refresh_whenThrowsGenericError_returnsErrorState() async throws {
		let dummyError = NSError(domain: "TestError", code: 999)
		let remote = AuthMockRemoteDataSource(refreshResult: .failure(dummyError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.refresh(request: anyRefreshRequest())

		guard case .error(let error as NSError) = result else {
			Issue.record("Expected .error(NSError)")
			return
		}
		#expect(error.domain == "TestError")
		#expect(error.code == 999)
	}

	// MARK: - logout

	@Test func logout_callsRemote() async throws {
		let remote = AuthMockRemoteDataSource(logoutResult: .success(anyEmptySuccessResponse()))
		let sut = makeSUT(remote: remote)

		_ = try await sut.logout()

		#expect(remote.invocations == [.logout])
	}

	@Test func logout_success_clearsLocalSession() async throws {
		let remote = AuthMockRemoteDataSource(logoutResult: .success(anyEmptySuccessResponse()))
		let local = AuthMockLocalDataSource(accessToken: "stale-token", refreshToken: "stale-refresh")
		let sut = makeSUT(remote: remote, local: local)

		let result = try await sut.logout()

		guard case .loaded = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(local.invocations == [.clearSession])
		#expect(local.getAccessToken() == nil)
	}

	@Test(arguments: [401, 404, 500])
	func logout_whenThrowsErrorResponse_returnsErrorStateAndKeepsSession(statusCode: Int) async throws {
		let expectedError = ErrorResponse(success: false, statusCode: statusCode, message: "Logout failed", errors: nil)
		let remote = AuthMockRemoteDataSource(logoutResult: .failure(expectedError))
		let local = AuthMockLocalDataSource(accessToken: "stale-token", refreshToken: "stale-refresh")
		let sut = makeSUT(remote: remote, local: local)

		let result = try await sut.logout()

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == statusCode)
		#expect(local.invocations.filter { $0 == .clearSession }.isEmpty)
	}

	@Test func logout_whenThrowsGenericError_returnsErrorState() async throws {
		let dummyError = NSError(domain: "TestError", code: 999)
		let remote = AuthMockRemoteDataSource(logoutResult: .failure(dummyError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.logout()

		guard case .error(let error as NSError) = result else {
			Issue.record("Expected .error(NSError)")
			return
		}
		#expect(error.domain == "TestError")
		#expect(error.code == 999)
	}

	// MARK: - logoutAll

	@Test func logoutAll_callsRemote() async throws {
		let remote = AuthMockRemoteDataSource(logoutAllResult: .success(anyEmptySuccessResponse()))
		let sut = makeSUT(remote: remote)

		_ = try await sut.logoutAll()

		#expect(remote.invocations == [.logoutAll])
	}

	@Test func logoutAll_success_clearsLocalSession() async throws {
		let remote = AuthMockRemoteDataSource(logoutAllResult: .success(anyEmptySuccessResponse()))
		let local = AuthMockLocalDataSource(accessToken: "stale-token", refreshToken: "stale-refresh")
		let sut = makeSUT(remote: remote, local: local)

		let result = try await sut.logoutAll()

		guard case .loaded = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(local.invocations == [.clearSession])
	}

	@Test(arguments: [401, 404, 500])
	func logoutAll_whenThrowsErrorResponse_returnsErrorState(statusCode: Int) async throws {
		let expectedError = ErrorResponse(success: false, statusCode: statusCode, message: "Logout failed", errors: nil)
		let remote = AuthMockRemoteDataSource(logoutAllResult: .failure(expectedError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.logoutAll()

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == statusCode)
	}

	@Test func logoutAll_whenThrowsGenericError_returnsErrorState() async throws {
		let dummyError = NSError(domain: "TestError", code: 999)
		let remote = AuthMockRemoteDataSource(logoutAllResult: .failure(dummyError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.logoutAll()

		guard case .error(let error as NSError) = result else {
			Issue.record("Expected .error(NSError)")
			return
		}
		#expect(error.domain == "TestError")
		#expect(error.code == 999)
	}

	// MARK: - getProfile

	@Test func getProfile_callsRemote() async throws {
		let remote = AuthMockRemoteDataSource(getProfileResult: .success(anyProfileSuccessResponse()))
		let sut = makeSUT(remote: remote)

		_ = try await sut.getProfile()

		#expect(remote.invocations == [.getProfile])
	}

	@Test func getProfile_success_returnsExpectedData() async throws {
		let user = anyUser(id: "42", name: "John Smith", email: "john.smith@example.com")
		let remote = AuthMockRemoteDataSource(getProfileResult: .success(anyProfileSuccessResponse(user: user)))
		let sut = makeSUT(remote: remote)

		let result = try await sut.getProfile()

		guard case .loaded(let response) = result else {
			Issue.record("Expected .loaded but got \(result)")
			return
		}
		#expect(response.data?.user == user)
	}

	@Test(arguments: [401, 404, 500])
	func getProfile_whenThrowsErrorResponse_returnsErrorState(statusCode: Int) async throws {
		let expectedError = ErrorResponse(success: false, statusCode: statusCode, message: "Request failed", errors: nil)
		let remote = AuthMockRemoteDataSource(getProfileResult: .failure(expectedError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.getProfile()

		guard case .error(let error as ErrorResponse) = result else {
			Issue.record("Expected .error(ErrorResponse)")
			return
		}
		#expect(error.statusCode == statusCode)
	}

	@Test func getProfile_whenThrowsGenericError_returnsErrorState() async throws {
		let dummyError = NSError(domain: "TestError", code: 999)
		let remote = AuthMockRemoteDataSource(getProfileResult: .failure(dummyError))
		let sut = makeSUT(remote: remote)

		let result = try await sut.getProfile()

		guard case .error(let error as NSError) = result else {
			Issue.record("Expected .error(NSError)")
			return
		}
		#expect(error.domain == "TestError")
		#expect(error.code == 999)
	}

	// MARK: - Helpers

	// `AuthDefaultRepository` is a struct (per the codebase's Repository convention), so
	// there's no reference to leak — `trackForMemoryLeak` doesn't apply here.
	private func makeSUT(
		remote: AuthMockRemoteDataSource = AuthMockRemoteDataSource(),
		local: AuthMockLocalDataSource = AuthMockLocalDataSource()
	) -> AuthDefaultRepository {
		AuthDefaultRepository(remoteDataSource: remote, localDataSource: local)
	}
}
