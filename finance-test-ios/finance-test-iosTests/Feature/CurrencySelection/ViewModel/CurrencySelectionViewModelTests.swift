//
//  CurrencySelectionViewModelTests.swift
//  finance-test-iosTests
//

import Combine
import Foundation
import Testing
@testable import finance_test_ios

@Suite("CurrencySelectionViewModel")
@MainActor
final class CurrencySelectionViewModelTests: MemoryLeakTrackingSuite {

	// MARK: - Tests

	@Test
	func onLoad_success_setsCurrenciesAndLoadedState() async {
		let expectedItems = [anyCurrencyItem()]
		let repository = CurrencyMockRepository(result: .loaded(anyCurrencyListSuccessResponse(items: expectedItems)))
		let sut = makeSUT(currencyRepository: repository)
		var receivedCurrencies = [[Currency.Response.CurrencyItem]]()
		var receivedStates = [CurrencySelectionViewModel.ViewState]()

		await confirmation("currencies emits expected value") { confirmCurrencies in
			await confirmation("viewState emits .loaded") { confirmState in
				let currenciesCancellable = sut.$currencies
					.dropFirst()
					.sink { currencies in
						receivedCurrencies.append(currencies)
						confirmCurrencies()
					}
				let stateCancellable = sut.$viewState
					.dropFirst(2)
					.sink { state in
						receivedStates.append(state)
						confirmState()
					}

				await sut.onLoad()

				currenciesCancellable.cancel()
				stateCancellable.cancel()
			}
		}

		#expect(repository.invocations == [.getCurrencies(anyGetCurrenciesRequest())])
		#expect(receivedCurrencies == [expectedItems])
		#expect(receivedStates == [.loaded])
	}

	@Test
	func onLoad_whenError_setsErrorState() async {
		let anyError = NSError(domain: "", code: -1)
		let repository = CurrencyMockRepository(result: .error(anyError))
		let sut = makeSUT(currencyRepository: repository)
		var receivedStates = [CurrencySelectionViewModel.ViewState]()

		await confirmation("viewState emits .error") { confirm in
			let cancellable = sut.$viewState
				.dropFirst(2)
				.sink { state in
					receivedStates.append(state)
					confirm()
				}

			await sut.onLoad()

			cancellable.cancel()
		}

		#expect(repository.invocations == [.getCurrencies(anyGetCurrenciesRequest())])
		#expect(receivedStates == [.error])
		#expect(sut.currencies.isEmpty)
	}

	@Test
	func select_updatesSelectedCurrency() {
		let sut = makeSUT()
		let newCurrency = anyCurrencyItem(id: "eur", code: "EUR", name: "Euro", symbol: "€")

		sut.select(newCurrency)

		#expect(sut.selectedCurrency == newCurrency)
	}

	@Test
	func confirmSelection_notifiesDelegateWithSelectedCurrency() {
		let delegate = CurrencySelectionDelegateSpy()
		let sut = makeSUT(delegate: delegate)
		let newCurrency = anyCurrencyItem(id: "eur", code: "EUR", name: "Euro", symbol: "€")
		sut.select(newCurrency)

		sut.confirmSelection()

		#expect(delegate.selectedCurrencies == [newCurrency])
	}

	// MARK: - Helpers

	private func makeSUT(
		selectedCurrency: Currency.Response.CurrencyItem = .usd,
		currencyRepository: CurrencyMockRepository = CurrencyMockRepository(),
		delegate: CurrencySelectionDelegateSpy = CurrencySelectionDelegateSpy(),
		file: StaticString = #filePath,
		line: UInt = #line
	) -> CurrencySelectionViewModel {
		let sut = CurrencySelectionViewModel(
			selectedCurrency: selectedCurrency,
			currencyRepository: currencyRepository,
			delegate: delegate
		)
		trackForMemoryLeak(sut, file: file, line: line)
		return sut
	}
}

private final class CurrencySelectionDelegateSpy: CurrencySelectionDelegate {
	private(set) var selectedCurrencies: [Currency.Response.CurrencyItem] = []

	nonisolated init() {}

	func didSelectCurrency(_ currency: Currency.Response.CurrencyItem) {
		selectedCurrencies.append(currency)
	}
}
