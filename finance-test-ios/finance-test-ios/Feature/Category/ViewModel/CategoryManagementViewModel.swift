//
//  CategoryManagementViewModel.swift
//  finance-test-ios
//

import Combine
import Foundation

/// Lets `AddCategoryViewModel` report back that the category list changed, without holding a
/// reference back to the concrete list view model.
@MainActor
protocol CategoryMutationDelegate: AnyObject {
	func categoryDidChange()
}

/// A single display row for "Your Categories" — flattens the two distinct sources (read-only
/// global `TransactionCategory.Response.CategoryItem` and user-owned `Sync.Response.UserCategoryItem`)
/// into one shape the list can render without caring which source a row came from.
struct CategoryRow: Identifiable, Hashable {
	let id: String
	let name: String
	let icon: String
	let colorHex: String?
}

@MainActor
final class CategoryManagementViewModel: ObservableObject {
	enum ViewState: Equatable {
		case initial
		case loading
		case loaded
		case error
	}

	@Published private(set) var viewState = ViewState.initial
	@Published var selectedType: TransactionType = .expense
	@Published private(set) var globalCategories: [TransactionCategory.Response.CategoryItem] = []
	@Published private(set) var userCategories: [Sync.Response.UserCategoryItem] = []

	private let categoryRepository: any TransactionCategoryRepository
	private let userCategoryRepository: any UserCategoryRepository

	init(
		categoryRepository: some TransactionCategoryRepository = TransactionCategoryDefaultRepository(),
		userCategoryRepository: some UserCategoryRepository = UserCategoryDefaultRepository()
	) {
		self.categoryRepository = categoryRepository
		self.userCategoryRepository = userCategoryRepository
	}

	var rows: [CategoryRow] {
		var result: [CategoryRow] = []

		for category in globalCategories where category.type == selectedType {
			let row = CategoryRow(
				id: category.id ?? UUID().uuidString,
				name: category.name ?? "Untitled",
				icon: CategoryIconResolver.symbol(for: category.icon),
				colorHex: category.color
			)
			result.append(row)
		}

		for category in userCategories where category.type == selectedType {
			let row = CategoryRow(
				id: category.id ?? UUID().uuidString,
				name: category.name ?? "Untitled",
				icon: CategoryIconResolver.symbol(for: category.icon),
				colorHex: category.color
			)
			result.append(row)
		}

		return result
	}

	func onLoad() async {
		viewState = .loading

		async let categoriesState = categoryRepository.getCategories(request: .init(type: nil, since: nil))
		async let userCategoriesState = userCategoryRepository.getUserCategories()

		do {
			let (categoriesResult, userCategoriesResult) = try await (categoriesState, userCategoriesState)

			guard
				case .loaded(let categoriesResponse) = categoriesResult,
				case .loaded(let userCategoriesResponse) = userCategoriesResult
			else {
				viewState = .error
				return
			}

			globalCategories = categoriesResponse.data?.items ?? []
			userCategories = userCategoriesResponse.data ?? []
			viewState = .loaded
		} catch {
			viewState = .error
		}
	}
}

extension CategoryManagementViewModel: CategoryMutationDelegate {
	func categoryDidChange() {
		Task { await onLoad() }
	}
}
