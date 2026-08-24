//
//  UserCategoryRepository.swift
//  finance-test-ios
//

protocol UserCategoryRepository {
	func getUserCategories() async throws -> RequestState<GeneralResponse<[Sync.Response.UserCategoryItem]>>

	func createUserCategory(
		request: UserCategory.Request.CreateUserCategory
	) async throws -> RequestState<GeneralResponse<Sync.Response.UserCategoryItem>>
}
