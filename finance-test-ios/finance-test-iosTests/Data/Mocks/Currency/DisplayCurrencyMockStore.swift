//
//  DisplayCurrencyMockStore.swift
//  finance-test-iosTests
//

import Combine
@testable import finance_test_ios

@MainActor
final class DisplayCurrencyMockStore: DisplayCurrencyStore {

	enum Invocation: Equatable {
		case refresh
	}

	private(set) var invocations: [Invocation] = []

	@Published private(set) var current: DisplayCurrency

	var currentPublisher: AnyPublisher<DisplayCurrency, Never> {
		$current.eraseToAnyPublisher()
	}

	/// What `refresh()` resolves to, so a test can stand in for a non-USD user.
	private let resolved: DisplayCurrency?

	init(current: DisplayCurrency = .fallback, resolved: DisplayCurrency? = nil) {
		self.current = current
		self.resolved = resolved
	}

	func refresh() async {
		invocations.append(.refresh)
		guard let resolved else { return }
		current = resolved
	}
}
