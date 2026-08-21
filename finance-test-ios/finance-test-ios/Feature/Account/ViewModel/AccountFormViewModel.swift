//
//  AccountFormViewModel.swift
//  finance-test-ios
//

import Combine
import Foundation

/// One shared form backs both create and edit — the Figma create/edit screens have identical
/// fields (initial balance, name, type, notes), unlike Currency where "edit rate" and "pick from
/// catalog" are genuinely different interactions.
@MainActor
final class AccountFormViewModel: ObservableObject {
	enum ViewState: Equatable {
		case idle
		case saving
	}

	enum AccountTypeOption: String, CaseIterable, Identifiable {
		case bankAccount = "bank_account"
		case creditCard = "credit_card"
		case cash
		case savings

		var id: String { rawValue }

		var label: String {
			switch self {
			case .bankAccount: "Bank Account"
			case .creditCard: "Credit Card"
			case .cash: "Cash"
			case .savings: "Savings"
			}
		}

		var icon: String {
			switch self {
			case .bankAccount: "building.columns.fill"
			case .creditCard: "creditcard.fill"
			case .cash: "banknote.fill"
			case .savings: "banknote"
			}
		}

		/// Falls back to `.bankAccount` for an unrecognized/legacy `type` string rather than
		/// failing the form entirely.
		static let fallback = AccountTypeOption.bankAccount

		/// Matches the fixed swatch each mock account already ships with
		/// (`Account.Response.AccountItem.mocks`), so real and mock rows stay visually consistent.
		var defaultColorHex: String {
			switch self {
			case .cash: "#22C55E"
			case .bankAccount: "#24389C"
			case .creditCard: "#6B7280"
			case .savings: "#F59E0B"
			}
		}
	}

	@Published var name: String
	@Published var initialBalanceText: String
	@Published var notes: String
	@Published var selectedType: AccountTypeOption
	@Published private(set) var viewState = ViewState.idle
	@Published private(set) var didFinish = false
	@Published var isSaveErrorPresented = false
	@Published private(set) var saveErrorMessage = ""

	let isEditing: Bool
	let navigationTitle: String

	private let existingAccountId: String?
	private let existingUserCurrencyId: String?
	private let existingColor: String?
	private let repository: any AccountRepository
	private let userCurrencyRepository: any UserCurrencyRepository
	private let delegate: any AccountMutationDelegate

	init(
		account: Account.Response.AccountItem?,
		repository: some AccountRepository = AccountDefaultRepository(),
		userCurrencyRepository: some UserCurrencyRepository = UserCurrencyDefaultRepository(),
		delegate: some AccountMutationDelegate
	) {
		self.existingAccountId = account?.id
		self.existingUserCurrencyId = account?.userCurrencyId
		self.existingColor = account?.color
		self.name = account?.name ?? ""
		self.initialBalanceText = account?.initialBalance ?? ""
		self.notes = account?.notes ?? ""
		self.selectedType = account.flatMap { AccountTypeOption(rawValue: $0.type ?? "") } ?? .fallback
		self.isEditing = account != nil
		self.navigationTitle = account != nil ? "Edit Account" : "Add Account"
		self.repository = repository
		self.userCurrencyRepository = userCurrencyRepository
		self.delegate = delegate
	}

	var isSaveDisabled: Bool {
		viewState == .saving || name.trimmingCharacters(in: .whitespaces).isEmpty
	}

	func save() async {
		let trimmedName = name.trimmingCharacters(in: .whitespaces)

		guard !trimmedName.isEmpty else {
			saveErrorMessage = String(localized: "Please enter an account name.")
			isSaveErrorPresented = true
			return
		}

		viewState = .saving

		let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
		let balanceText = initialBalanceText.trimmingCharacters(in: .whitespaces)

		do {
			let state: RequestState<GeneralResponse<Account.Response.AccountItem>>

			if let existingAccountId, let existingUserCurrencyId {
				let request = Account.Request.UpdateAccount(
					userCurrencyId: existingUserCurrencyId,
					name: trimmedName,
					type: selectedType.rawValue,
					notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
					color: existingColor ?? selectedType.defaultColorHex,
					initialBalance: balanceText.isEmpty ? nil : balanceText,
					isDefault: nil
				)
				state = try await repository.updateAccount(id: existingAccountId, request: request)
			} else {
				let userCurrencyId = try await resolveDefaultUserCurrencyId()
				let request = Account.Request.CreateAccount(
					userCurrencyId: userCurrencyId,
					name: trimmedName,
					type: selectedType.rawValue,
					notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
					color: selectedType.defaultColorHex,
					initialBalance: balanceText.isEmpty ? nil : balanceText,
					isDefault: nil
				)
				state = try await repository.createAccount(request: request)
			}

			switch state {
			case .loaded:
				delegate.accountDidChange()
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

	/// The create form has no currency picker (per Figma) — new accounts default to the user's
	/// anchor currency, falling back to the first currency on file if none is marked anchor yet.
	private func resolveDefaultUserCurrencyId() async throws -> String {
		let state = try await userCurrencyRepository.getUserCurrencies(request: .init(since: nil))

		guard
			case .loaded(let response) = state,
			let items = response.data?.items,
			let userCurrencyId = (items.first(where: { $0.isAnchor == true }) ?? items.first)?.id
		else {
			throw ErrorResponse(
				success: false, statusCode: -1,
				message: "Add a currency before creating an account.", errors: nil
			)
		}

		return userCurrencyId
	}

	private func handleSaveError(_ error: Error) {
		viewState = .idle
		saveErrorMessage = (error as? ErrorResponse)?.message ?? String(localized: "Something went wrong. Please try again.")
		isSaveErrorPresented = true
	}
}
