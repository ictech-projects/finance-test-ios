//
//  ReportsRepository.swift
//  finance-test-ios
//

protocol ReportsRepository {
	func getPeriodSummary(
		request: Reports.Request.GetPeriodSummary
	) async throws -> RequestState<GeneralResponse<Reports.Response.PeriodSummary>>
}
