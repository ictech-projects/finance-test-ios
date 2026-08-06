//
//  SyncMockRepository.swift
//  finance-test-iosTests
//

@testable import finance_test_ios

/// Test double for `SyncRepository`, distinct from the app target's `SyncMockRepository` (which
/// stands in for the real backend until the auth module lands). This one lets each test configure
/// an arbitrary `RequestState` result and records invocations for assertions.
final class SyncMockRepository: SyncRepository {

	enum Invocation: Equatable {
		case push(Sync.Request.Push)
	}

	private(set) var invocations: [Invocation] = []

	private let result: RequestState<GeneralResponse<Sync.Response.PushResult>>

	init(result: RequestState<GeneralResponse<Sync.Response.PushResult>> = .idle) {
		self.result = result
	}

	func push(
		request: Sync.Request.Push
	) async throws -> RequestState<GeneralResponse<Sync.Response.PushResult>> {
		invocations.append(.push(request))
		return result
	}
}
