//
//  AccountFormView.swift
//  finance-test-ios
//

import SwiftUI

struct AccountFormView<Delegate: AccountMutationDelegate>: View {
	@StateObject private var viewModel: AccountFormViewModel
	@Environment(\.dismiss) private var dismiss

	init(account: Account.Response.AccountItem?, delegate: Delegate) {
		_viewModel = StateObject(wrappedValue: AccountFormViewModel(account: account, delegate: delegate))
	}

	var body: some View {
		VStack(spacing: 0) {
			TopBarView(title: viewModel.navigationTitle, onBackPressed: { dismiss() })

			ScrollView {
				VStack(alignment: .leading, spacing: 24) {
					initialBalanceCard
					nameField
					typeSection
					notesField
				}
				.padding(16)
			}

			PrimaryButton(size: .large, backgroundColor: .brandPrimary, isDisabled: viewModel.isSaveDisabled, action: {
				Task { await viewModel.save() }
			}) {
				if viewModel.viewState == .saving {
					ProgressView().tint(.white)
				} else {
					Label("Save Account", systemImage: "square.and.arrow.down")
				}
			}
			.padding(16)
		}
		.background(Color.splashSurface.ignoresSafeArea())
		.navigationBarHidden(true)
		.onChange(of: viewModel.didFinish) { _, didFinish in
			if didFinish { dismiss() }
		}
		.baseAlert(
			isPresented: $viewModel.isSaveErrorPresented,
			type: .error,
			title: "Couldn't Save",
			message: viewModel.saveErrorMessage,
			confirmLabel: Text("OK"),
			confirmAction: {}
		)
	}

	private var initialBalanceCard: some View {
		VStack(spacing: 8) {
			Text("INITIAL BALANCE")
				.font(.baseStyle(size: 12, weight: .bold))
				.tracking(0.6)
				.foregroundStyle(.neutral60)

			HStack(spacing: 4) {
				Text("$")
					.font(.baseStyle(size: 28, weight: .bold))
					.foregroundStyle(.brandPrimary)

				TextField("0.00", text: $viewModel.initialBalanceText)
					.font(.baseStyle(size: 28, weight: .bold))
					.foregroundStyle(.neutral100)
					.keyboardType(.decimalPad)
					.multilineTextAlignment(.center)
			}
		}
		.padding(20)
		.frame(maxWidth: .infinity)
		.background(RoundedRectangle(cornerRadius: 16).fill(Color.moreSectionCardBackground))
	}

	private var nameField: some View {
		TextField("e.g., Chase Checking", text: $viewModel.name)
			.withTitle(Text("Account Name"), keyboardType: .default)
	}

	private var typeSection: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Account Type")
				.font(.baseStyle(size: 13, weight: .semibold))
				.foregroundStyle(.neutral90)

			LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
				ForEach(AccountFormViewModel.AccountTypeOption.allCases) { option in
					AccountTypeCell(
						option: option,
						isSelected: viewModel.selectedType == option,
						onTap: { viewModel.selectedType = option }
					)
				}
			}
		}
	}

	private var notesField: some View {
		TextEditor(text: $viewModel.notes)
			.withTitle(text: $viewModel.notes, placeholder: "Add additional details about this account...", "Notes (Optional)")
	}
}

private struct AccountTypeCell: View {
	let option: AccountFormViewModel.AccountTypeOption
	let isSelected: Bool
	let onTap: () -> Void

	var body: some View {
		Button(action: onTap) {
			VStack(spacing: 8) {
				ZStack {
					Circle()
						.fill(isSelected ? Color.brandPrimary : Color.moreSectionCardBackground)
						.frame(width: 40, height: 40)

					Image(systemName: option.icon)
						.foregroundStyle(isSelected ? .white : .neutral60)
				}

				Text(option.label)
					.font(.baseStyle(size: 13, weight: .semibold))
					.foregroundStyle(isSelected ? .brandPrimary : .neutral90)
			}
			.frame(maxWidth: .infinity)
			.padding(.vertical, 16)
			.background(
				RoundedRectangle(cornerRadius: 12)
					.fill(Color.splashSurface)
			)
			.overlay(
				RoundedRectangle(cornerRadius: 12)
					.stroke(isSelected ? Color.brandPrimary : Color.moreHairline.opacity(0.4), lineWidth: isSelected ? 2 : 1)
			)
		}
		.buttonStyle(.plain)
	}
}

private final class PreviewAccountMutationDelegate: AccountMutationDelegate {
	func accountDidChange() {}
}

#Preview("Add") {
	NavigationStack {
		AccountFormView(account: nil, delegate: PreviewAccountMutationDelegate())
	}
}

#Preview("Edit") {
	NavigationStack {
		AccountFormView(account: Account.Response.AccountItem.mocks[1], delegate: PreviewAccountMutationDelegate())
	}
}
