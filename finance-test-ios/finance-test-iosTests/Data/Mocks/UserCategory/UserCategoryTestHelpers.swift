//
//  UserCategoryTestHelpers.swift
//  finance-test-iosTests
//

@testable import finance_test_ios

func anyCreateUserCategoryRequest(
	name: String = "Side Hustle",
	type: TransactionType = .income,
	icon: String = "briefcase",
	color: String? = "#24389C"
) -> UserCategory.Request.CreateUserCategory {
	UserCategory.Request.CreateUserCategory(name: name, type: type, icon: icon, color: color)
}

func anyUserCategoryListSuccessResponse(
	items: [Sync.Response.UserCategoryItem] = [anyUserCategoryItem()]
) -> GeneralResponse<[Sync.Response.UserCategoryItem]> {
	GeneralResponse(
		success: true,
		statusCode: 200,
		message: "User categories fetched.",
		data: items
	)
}

func anyAppliedUserCategoryChangeResult(
	clientChangeId: String? = "c1",
	id: String? = "01K3UT0000000000000000UT02",
	item: Sync.Response.UserCategoryItem = anyUserCategoryItem(id: "01K3UT0000000000000000UT02")
) -> Sync.Response.ChangeResult {
	Sync.Response.ChangeResult(
		clientChangeId: clientChangeId, id: id, entity: "user_category", status: "applied",
		record: try? JSONValue(encoding: item), error: nil
	)
}
