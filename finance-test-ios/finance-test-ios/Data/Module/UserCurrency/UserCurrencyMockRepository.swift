//
//  UserCurrencyMockRepository.swift
//  finance-test-ios
//

import Foundation

struct UserCurrencyMockRepository: UserCurrencyRepository {

	func getUserCurrencies(
		request: UserCurrency.Request.GetUserCurrencies
	) async -> RequestState<GeneralResponse<UserCurrency.Response.UserCurrencyList>> {
		try? await Task.sleep(nanoseconds: 400_000_000)

		return .loaded(
			GeneralResponse(
				success: true,
				statusCode: 200,
				message: "User currencies fetched.",
				data: UserCurrency.Response.UserCurrencyList(
					items: UserCurrency.Response.UserCurrencyItem.mocks,
					serverTime: nil
				)
			)
		)
	}

	func createUserCurrency(
		request: UserCurrency.Request.CreateUserCurrency
	) async -> RequestState<GeneralResponse<UserCurrency.Response.UserCurrencyItem>> {
		try? await Task.sleep(nanoseconds: 400_000_000)

		return .loaded(
			GeneralResponse(
				success: true,
				statusCode: 201,
				message: "User currency added.",
				data: UserCurrency.Response.UserCurrencyItem(
					id: "01K3UC0000000000000000UC99", userId: "01K3US0000000000000000US01",
					currencyId: request.currencyId, exchangeRate: request.exchangeRate ?? "1",
					isAnchor: request.isAnchor ?? false, createdAt: nil, updatedAt: nil
				)
			)
		)
	}

	func updateUserCurrency(
		id: String,
		request: UserCurrency.Request.UpdateUserCurrency
	) async -> RequestState<GeneralResponse<UserCurrency.Response.UserCurrencyItem>> {
		try? await Task.sleep(nanoseconds: 400_000_000)

		return .loaded(
			GeneralResponse(
				success: true,
				statusCode: 200,
				message: "User currency updated.",
				data: UserCurrency.Response.UserCurrencyItem(
					id: id, userId: "01K3US0000000000000000US01",
					currencyId: request.currencyId, exchangeRate: request.exchangeRate ?? "1",
					isAnchor: request.isAnchor ?? false, createdAt: nil, updatedAt: nil
				)
			)
		)
	}
}
