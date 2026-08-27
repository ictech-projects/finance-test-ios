//
//  OpenAddExpenseIntentTests.swift
//  finance-test-iosTests
//

import Testing
@testable import finance_test_ios

/// `AppIntentRouter` is a singleton (the intent that publishes to it has no way to be handed a
/// dependency by the system), so each test clears it rather than making a fresh instance.
@Suite("OpenAddExpenseIntent", .serialized)
@MainActor
struct OpenAddExpenseIntentTests {

	@Test
	func perform_publishesAddExpenseRequest() async throws {
		AppIntentRouter.shared.clear()

		_ = try await OpenAddExpenseIntent().perform()

		#expect(AppIntentRouter.shared.pendingRequest == .addExpense)
	}

	/// The control opens the app; only the UI that acted on the request clears it. A request that
	/// arrives before its consumer exists (a control tap cold-launching the app) has to survive
	/// until then, so `perform()` must not consume its own request.
	@Test
	func perform_leavesRequestPendingForItsConsumer() async throws {
		AppIntentRouter.shared.clear()

		_ = try await OpenAddExpenseIntent().perform()
		#expect(AppIntentRouter.shared.pendingRequest != nil)

		AppIntentRouter.shared.clear()
		#expect(AppIntentRouter.shared.pendingRequest == nil)
	}

	/// Two taps in a row are two requests: without the consumer's `clear()` in between, the second
	/// `@Published` write would be a no-op and `task(id:)` would never re-fire.
	@Test
	func perform_afterConsumerCleared_publishesAgain() async throws {
		AppIntentRouter.shared.clear()

		_ = try await OpenAddExpenseIntent().perform()
		AppIntentRouter.shared.clear()
		_ = try await OpenAddExpenseIntent().perform()

		#expect(AppIntentRouter.shared.pendingRequest == .addExpense)

		AppIntentRouter.shared.clear()
	}
}
