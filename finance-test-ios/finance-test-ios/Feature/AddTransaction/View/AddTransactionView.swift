//
//  AddTransactionView.swift
//  finance-test-ios
//

import SwiftUI

struct AddTransactionView: View {
	@StateObject private var viewModel: AddTransactionViewModel
	@Environment(\.dismiss) private var dismiss

	init(delegate: some AddTransactionDelegate) {
		_viewModel = StateObject(wrappedValue: AddTransactionViewModel(delegate: delegate))
	}

	var body: some View {
		VStack(spacing: 0) {
			header
			content
		}
		.background(Color.neutral20.ignoresSafeArea())
		.task {
			await viewModel.onLoad()
		}
		.entityPickerSheet(
			isPresented: $viewModel.isAccountPickerPresented,
			title: "Select Account",
			items: viewModel.accounts,
			selection: viewModel.selectedAccount,
			onSelect: viewModel.selectAccount
		) { account, isSelected in
			AccountPickerRow(account: account, isSelected: isSelected)
		}
		.entityPickerSheet(
			isPresented: $viewModel.isCategoryPickerPresented,
			title: "Select Category",
			items: viewModel.categoriesForCurrentType,
			selection: viewModel.selectedCategory,
			onSelect: viewModel.selectCategory
		) { category, isSelected in
			CategoryPickerRow(category: category, isSelected: isSelected)
		}
		.sheet(isPresented: $viewModel.isDatePickerPresented) {
			SingleDatePickerView(
				selection: $viewModel.date,
				range: Self.dateRange,
				onDoneTapped: viewModel.dismissDatePicker
			)
			.presentationDetents([.medium])
		}
		.overlay {
			OverlayCircularProgressView(show: viewModel.isSaving)
		}
		.baseAlert(
			isPresented: $viewModel.isSaveErrorPresented,
			type: .error,
			title: "Couldn't Save Transaction",
			message: viewModel.saveErrorMessage,
			confirmLabel: Text("OK"),
			confirmAction: {}
		)
	}

	private var header: some View {
		ZStack {
			Text("New Transaction")
				.font(.baseStyle(size: 18, weight: .bold))
				.foregroundStyle(.brandPrimary)

			HStack {
				Button {
					dismiss()
				} label: {
					Image(systemName: "xmark")
						.font(.baseStyle(size: 18, weight: .semibold))
						.foregroundStyle(.brandPrimary)
						.frame(width: 30, height: 30)
				}

				Spacer()
			}
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 12)
		.background(
			Color(.systemBackground)
				.overlay(alignment: .bottom) {
					Rectangle().fill(Color.neutral50).frame(height: 1)
				}
		)
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.viewState {
		case .initial, .loading:
			ProgressView()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
		case .error:
			ContentUnavailableView(
				"Couldn't load accounts or categories",
				systemImage: "exclamationmark.triangle",
				description: Text("Please try again later.")
			)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		case .loaded:
			formContent
		}
	}

	private var formContent: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				AddTransactionTypeToggle(selection: viewModel.type, onSelect: viewModel.selectType)
					.staggeredAppear(index: 0)

				amountField
					.staggeredAppear(index: 1)

				optionField(
					title: "Category",
					value: viewModel.selectedCategory?.name ?? "Select category",
					errorMessage: viewModel.categoryErrorMessage,
					action: viewModel.presentCategoryPicker
				)
				.staggeredAppear(index: 2)

				optionField(
					title: "Account",
					value: viewModel.selectedAccount?.name ?? "Select account",
					errorMessage: viewModel.accountErrorMessage,
					action: viewModel.presentAccountPicker
				)
				.staggeredAppear(index: 3)

				dateField
					.staggeredAppear(index: 4)

				noteField
					.staggeredAppear(index: 5)

				PrimaryButton(size: .large, isDisabled: viewModel.isSaveDisabled, action: submit) {
					Text("Save Transaction")
				}
				.padding(.top, 8)
				.staggeredAppear(index: 6)
			}
			.padding(16)
			.padding(.bottom, 24)
		}
	}

	private var amountField: some View {
		TextField("0.00", text: $viewModel.amountText)
			.keyboardType(.decimalPad)
			.onChange(of: viewModel.amountText) {
				viewModel.amountDidChange()
			}
			.modifier(
				TextFieldWithTitle(
					title: Text("Amount"),
					keyboardType: .decimalPad,
					errorDescription: viewModel.amountErrorMessage.map(Text.init)
				)
			)
	}

	private var dateField: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Date")
				.font(.baseStyle(size: 16, weight: .medium))
				.foregroundStyle(.neutral90)

			DatePickerField(
				selectedDateText: Text(viewModel.date.formatted(date: .abbreviated, time: .omitted)),
				action: viewModel.presentDatePicker
			)
		}
	}

	private var noteField: some View {
		TextField("Add a note (optional)", text: $viewModel.note)
			.modifier(TextFieldWithTitle(title: Text("Note")))
	}

	private func optionField(
		title: String,
		value: String,
		errorMessage: String?,
		action: @escaping () -> Void
	) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			TitledOptionField(title: Text(title), value: value, height: 48, action: action)

			if let errorMessage {
				Text(errorMessage)
					.font(.baseStyle(size: 14, weight: .regular))
					.foregroundStyle(.dangerMain)
			}
		}
	}

	private func submit() {
		Task { await viewModel.save() }
	}

	private static var dateRange: ClosedRange<Date> {
		let start = Calendar.current.date(byAdding: .year, value: -2, to: .now) ?? .now
		let end = Calendar.current.date(byAdding: .year, value: 1, to: .now) ?? .now
		return start...end
	}
}

private final class PreviewAddTransactionDelegate: AddTransactionDelegate {
	func didCreateTransaction(_ item: TransactionRecord.Response.TransactionItem) {}
}

#Preview {
	AddTransactionView(delegate: PreviewAddTransactionDelegate())
}
