//
//  AddCategoryViewModel.swift
//  finance-test-ios
//

import Combine
import Foundation

@MainActor
final class AddCategoryViewModel: ObservableObject {
	enum ViewState: Equatable {
		case idle
		case saving
	}

	/// A fixed curated set — there's no icon-catalog endpoint, so this mirrors the Figma's grid of
	/// common category icons as SF Symbols.
	static let iconOptions: [String] = [
		"cart", "fork.knife", "car.fill", "house.fill", "cross.case.fill", "arrow.up.right",
		"wallet.pass", "airplane", "graduationcap.fill", "building.columns.fill", "pawprint.fill",
		"figure.walk", "briefcase.fill", "sparkles", "chart.pie.fill"
	]

	/// A fixed preset palette matching the Figma's swatch grid — there's no color-catalog endpoint.
	static let colorOptions: [String] = [
		"#2563EB", "#22C55E", "#EF4444", "#F97316", "#6B7280", "#92400E", "#991B1B"
	]

	@Published var name: String = ""
	@Published var selectedType: TransactionType
	@Published var selectedIcon: String = AddCategoryViewModel.iconOptions[0]
	@Published var selectedColorHex: String = AddCategoryViewModel.colorOptions[0]
	@Published private(set) var viewState = ViewState.idle
	@Published private(set) var didFinish = false
	@Published var isSaveErrorPresented = false
	@Published private(set) var saveErrorMessage = ""

	private let repository: any UserCategoryRepository
	private let delegate: any CategoryMutationDelegate

	init(
		initialType: TransactionType,
		repository: some UserCategoryRepository = UserCategoryDefaultRepository(),
		delegate: some CategoryMutationDelegate
	) {
		self.selectedType = initialType
		self.repository = repository
		self.delegate = delegate
	}

	var isSaveDisabled: Bool {
		viewState == .saving || name.trimmingCharacters(in: .whitespaces).isEmpty
	}

	func save() async {
		let trimmedName = name.trimmingCharacters(in: .whitespaces)

		guard !trimmedName.isEmpty else {
			saveErrorMessage = String(localized: "Please enter a category name.")
			isSaveErrorPresented = true
			return
		}

		viewState = .saving

		do {
			let request = UserCategory.Request.CreateUserCategory(
				name: trimmedName, type: selectedType, icon: selectedIcon, color: selectedColorHex
			)
			let state = try await repository.createUserCategory(request: request)

			switch state {
			case .loaded:
				delegate.categoryDidChange()
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
}
