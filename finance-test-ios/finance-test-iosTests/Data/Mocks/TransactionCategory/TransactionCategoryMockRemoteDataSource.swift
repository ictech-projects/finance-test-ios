//
//  TransactionCategoryMockRemoteDataSource.swift
//  finance-test-iosTests
//

@testable import finance_test_ios

final class TransactionCategoryMockRemoteDataSource: TransactionCategoryRemoteDataSource {

	enum Invocation: Equatable {
		case getCategories(TransactionCategory.Request.GetCategories)
	}

	private(set) var invocations: [Invocation] = []

	private let getCategoriesResult: Result<GeneralResponse<TransactionCategory.Response.CategoryList>, Error>

	init(
		getCategoriesResult: Result<GeneralResponse<TransactionCategory.Response.CategoryList>, Error> = .success(
			anyCategoryListSuccessResponse()
		)
	) {
		self.getCategoriesResult = getCategoriesResult
	}

	func getCategories(
		request: TransactionCategory.Request.GetCategories
	) async throws -> GeneralResponse<TransactionCategory.Response.CategoryList> {
		invocations.append(.getCategories(request))
		return try getCategoriesResult.get()
	}
}

func anyCategoryItem(
	id: String = "01K3CT0000000000000000CT01",
	name: String = "Dining & Drinks",
	type: TransactionType = .expense
) -> TransactionCategory.Response.CategoryItem {
	TransactionCategory.Response.CategoryItem(
		id: id, name: name, type: type,
		icon: "fork.knife", color: "#F97316", createdAt: nil, updatedAt: nil, deletedAt: nil
	)
}

func anyGetCategoriesRequest() -> TransactionCategory.Request.GetCategories {
	TransactionCategory.Request.GetCategories(type: nil, since: nil)
}

func anyCategoryListSuccessResponse(
	items: [TransactionCategory.Response.CategoryItem] = [anyCategoryItem()]
) -> GeneralResponse<TransactionCategory.Response.CategoryList> {
	GeneralResponse(
		success: true,
		statusCode: 200,
		message: "Categories fetched.",
		data: TransactionCategory.Response.CategoryList(items: items, serverTime: nil)
	)
}
