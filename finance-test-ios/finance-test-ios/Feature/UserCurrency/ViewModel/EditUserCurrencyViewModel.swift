//
//  EditUserCurrencyViewModel.swift
//  finance-test-ios
//

import Combine
import Foundation

@MainActor
final class EditUserCurrencyViewModel: ObservableObject {
	enum ViewState: Equatable {
		case idle
		case saving
	}

	@Published var exchangeRateText: String
	@Published private(set) var viewState = ViewState.idle
	@Published private(set) var didFinish = false
	@Published var isSaveErrorPresented = false
	@Published private(set) var saveErrorMessage = ""

	let currencyName: String
	let currencyCode: String
	let currencySymbol: String
	let anchorCurrencyCode: String
	let lastUpdatedLabel: String

	private let userCurrencyId: String
	private let currencyId: String
	private let isAnchor: Bool
	private let repository: any UserCurrencyRepository
	private let delegate: any UserCurrencyMutationDelegate

	init(
		displayItem: UserCurrencyDisplayItem,
		anchorCurrencyCode: String,
		repository: some UserCurrencyRepository = UserCurrencyDefaultRepository(),
		delegate: some UserCurrencyMutationDelegate
	) {
		self.userCurrencyId = displayItem.item.id ?? ""
		self.currencyId = displayItem.item.currencyId ?? ""
		self.isAnchor = displayItem.item.isAnchor ?? false
		self.exchangeRateText = displayItem.item.exchangeRate ?? "1"
		self.currencyName = displayItem.currency?.name ?? "Unknown Currency"
		self.currencyCode = displayItem.currency?.code ?? "—"
		self.currencySymbol = displayItem.currency?.symbol ?? "?"
		self.anchorCurrencyCode = anchorCurrencyCode
		self.lastUpdatedLabel = Self.formattedLastUpdated(displayItem.item.updatedAt)
		self.repository = repository
		self.delegate = delegate
	}

	var isSaveDisabled: Bool {
		viewState == .saving || Double(exchangeRateText.trimmingCharacters(in: .whitespaces)) == nil
	}

	func save() async {
		guard
			let rate = Double(exchangeRateText.trimmingCharacters(in: .whitespaces)),
			rate > 0
		else {
			saveErrorMessage = String(localized: "Please enter a valid exchange rate.")
			isSaveErrorPresented = true
			return
		}

		viewState = .saving

		do {
			let state = try await repository.updateUserCurrency(
				id: userCurrencyId,
				request: .init(currencyId: currencyId, exchangeRate: String(rate), isAnchor: isAnchor)
			)
			switch state {
			case .loaded:
				delegate.userCurrencyDidChange()
				didFinish = true
			case .error(let error):
				handleSaveError(error)
			default:
				viewState = .idle
			}
		} catch {
			handleSaveError(error)
		}
	}

	private func handleSaveError(_ error: Error) {
		viewState = .idle
		saveErrorMessage = (error as? ErrorResponse)?.message ?? String(localized: "Something went wrong. Please try again.")
		isSaveErrorPresented = true
	}

	private static func formattedLastUpdated(_ isoString: String?) -> String {
		guard let isoString else { return "—" }

		let isoFormatter = ISO8601DateFormatter()
		isoFormatter.formatOptions = [.withInternetDateTime]
		guard let date = isoFormatter.date(from: isoString) else { return "—" }

		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		return formatter.string(from: date)
	}
}
