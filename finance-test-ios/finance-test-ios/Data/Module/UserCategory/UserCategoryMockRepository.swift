//
//  UserCategoryMockRepository.swift
//  finance-test-ios
//

import Foundation

/// Stands in for `UserCategoryDefaultRepository` until the auth module exists and `/sync/push`
/// `/sync/pull` can actually be called. Swap the default in consuming ViewModels to
/// `UserCategoryDefaultRepository()` once a valid access token is available.
struct UserCategoryMockRepository: UserCategoryRepository {

	func getUserCategories() async -> RequestState<GeneralResponse<[Sync.Response.UserCategoryItem]>> {
		try? await Task.sleep(nanoseconds: 400_000_000)

		return .loaded(
			GeneralResponse(
				success: true,
				statusCode: 200,
				message: "User categories fetched.",
				data: [
					Sync.Response.UserCategoryItem(
						id: "01K3UT0000000000000000UT01", userId: "01K3US0000000000000000US01",
						name: "Side Hustle", type: .income, icon: "briefcase", color: "#24389C",
						createdAt: nil, updatedAt: nil, deletedAt: nil
					)
				]
			)
		)
	}

	func createUserCategory(
		request: UserCategory.Request.CreateUserCategory
	) async -> RequestState<GeneralResponse<Sync.Response.UserCategoryItem>> {
		try? await Task.sleep(nanoseconds: 400_000_000)

		return .loaded(
			GeneralResponse(
				success: true,
				statusCode: 201,
				message: "Category added.",
				data: Sync.Response.UserCategoryItem(
					id: "01K3UT0000000000000000UT99", userId: "01K3US0000000000000000US01",
					name: request.name, type: request.type, icon: request.icon, color: request.color,
					createdAt: nil, updatedAt: nil, deletedAt: nil
				)
			)
		)
	}
}
