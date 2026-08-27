//
//  CategoryIconResolverTests.swift
//  finance-test-iosTests
//

import Foundation
import Testing
import UIKit
@testable import finance_test_ios

@Suite("CategoryIconResolver")
struct CategoryIconResolverTests {

	/// Every Lucide name the backend actually seeds, taken from a live `/sync/pull`.
	private static let backendIcons = [
		"utensils", "shopping-basket", "shopping-bag", "bus", "home", "plane", "zap",
		"credit-card", "receipt", "graduation-cap", "film", "heart-pulse", "shield",
		"minus-circle", "plus-circle", "trending-up", "rotate-ccw", "briefcase", "store",
		"gift", "percent"
	]

	@Test(arguments: backendIcons)
	func symbol_forEveryBackendIcon_resolvesToARealSFSymbol(icon: String) {
		let symbol = CategoryIconResolver.symbol(for: icon)

		#expect(symbol != CategoryIconResolver.fallbackSymbol, "\(icon) should map to a specific symbol, not the fallback")
		#expect(UIImage(systemName: symbol) != nil, "\(icon) mapped to \(symbol), which is not a real SF Symbol")
	}

	@Test(arguments: AddCategoryViewModel.iconOptions)
	func symbol_forInAppIconOptions_passesThroughUnchanged(icon: String) {
		#expect(CategoryIconResolver.symbol(for: icon) == icon)
		#expect(UIImage(systemName: icon) != nil)
	}

	@Test
	func symbol_forUnmappedLucideName_fallsBackRatherThanRenderingBlank() {
		// A kebab-cased name we don't know is certainly not an SF Symbol.
		#expect(CategoryIconResolver.symbol(for: "some-new-lucide-icon") == CategoryIconResolver.fallbackSymbol)
	}

	@Test(arguments: [nil, ""])
	func symbol_forMissingIcon_returnsFallback(icon: String?) {
		#expect(CategoryIconResolver.symbol(for: icon) == CategoryIconResolver.fallbackSymbol)
	}

	@Test
	func fallbackSymbol_isItselfARealSFSymbol() {
		#expect(UIImage(systemName: CategoryIconResolver.fallbackSymbol) != nil)
	}
}
