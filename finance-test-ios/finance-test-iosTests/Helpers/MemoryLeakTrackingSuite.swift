//
//  MemoryLeakTrackingSuite.swift
//  finance-test-iosTests
//

import Testing

/// Base class for Swift Testing `@Suite`s that need `trackForMemoryLeak`. Swift Testing
/// instantiates a fresh suite instance per `@Test` function, so `deinit` here fires right
/// after each test completes — the same moment XCTest's `addTeardownBlock` would.
class MemoryLeakTrackingSuite {

	private var trackedInstances: [(check: () -> AnyObject?, file: StaticString, line: UInt)] = []

	init() {}

	func trackForMemoryLeak(
		_ instance: AnyObject,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		trackedInstances.append((check: { [weak instance] in instance }, file: file, line: line))
	}

	deinit {
		for tracked in trackedInstances where tracked.check() != nil {
			Issue.record("Instance from \(tracked.file):\(tracked.line) should have been deallocated. Potential memory leak.")
		}
	}
}
