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
			if case .loaded = viewModel.viewState {
				saveButtonBar
			}
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
						.font(.baseStyle(size: 16, weight: .semibold))
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
					Rectangle().fill(Color.recordsCardBorder).frame(height: 1)
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
			VStack(spacing: 0) {
				AddTransactionTypeToggle(selection: viewModel.type, onSelect: viewModel.selectType)
					.padding(.horizontal, 16)
					.padding(.vertical, 24)
					.staggeredAppear(index: 0)

				numericDisplay
					.staggeredAppear(index: 1)

				VStack(alignment: .leading, spacing: 16) {
					categorySection
						.staggeredAppear(index: 2)

					detailsSection
						.staggeredAppear(index: 3)
				}
				.padding(16)
			}
		}
	}

	private var saveButtonBar: some View {
		PrimaryButton(
			size: .large,
			backgroundColor: .addTransactionFabBackground,
			isDisabled: viewModel.isSaveDisabled,
			action: submit
		) {
			HStack(spacing: 8) {
				Image(systemName: "checkmark.circle.fill")
				Text("Save Transaction")
			}
		}
		.padding(.horizontal, 16)
		.padding(.top, 12)
		.padding(.bottom, 24)
		.background(
			Color(.systemBackground)
				.overlay(alignment: .top) {
					Rectangle().fill(Color.recordsCardBorder).frame(height: 1)
				}
				.ignoresSafeArea(edges: .bottom)
		)
	}

	private var numericDisplay: some View {
		VStack(spacing: 4) {
			Text("Enter Amount")
				.font(.baseStyle(size: 14, weight: .semibold))
				.foregroundStyle(.addTransactionMutedLabel)

			HStack(spacing: 0) {
				Text("$")
					.foregroundStyle(.recordsCardBorder)
				TextField("0.00", text: $viewModel.amountText)
					.keyboardType(.decimalPad)
					.fixedSize()
					.onChange(of: viewModel.amountText) {
						viewModel.amountDidChange()
					}
			}
			.font(.system(size: 57, weight: .regular))
			.foregroundStyle(viewModel.type == .expense ? .dangerMain : .successMain)
			.tracking(-0.25)

			if let amountErrorMessage = viewModel.amountErrorMessage {
				Text(amountErrorMessage)
					.font(.baseStyle(size: 14, weight: .regular))
					.foregroundStyle(.dangerMain)
			}
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 8)
	}

	private var categorySection: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Category")
				.font(.baseStyle(size: 14, weight: .semibold))
				.foregroundStyle(.recordsNeutralIconTint)

			LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
				ForEach(viewModel.categoriesForCurrentType, id: \.self) { category in
					CategoryGridItem(
						category: category,
						isSelected: category == viewModel.selectedCategory,
						action: { viewModel.selectCategory(category) }
					)
				}
			}

			if let categoryErrorMessage = viewModel.categoryErrorMessage {
				Text(categoryErrorMessage)
					.font(.baseStyle(size: 14, weight: .regular))
					.foregroundStyle(.dangerMain)
			}
		}
	}

	private var detailsSection: some View {
		VStack(alignment: .leading, spacing: 16) {
			HStack(spacing: 16) {
				BentoInfoCard(
					systemImageName: "creditcard",
					label: "Account",
					value: viewModel.selectedAccount?.name ?? "Select account",
					action: viewModel.presentAccountPicker
				)

				BentoInfoCard(
					systemImageName: "calendar",
					label: "Date",
					value: viewModel.date.formatted(date: .abbreviated, time: .omitted),
					action: viewModel.presentDatePicker
				)
			}

			if let accountErrorMessage = viewModel.accountErrorMessage {
				Text(accountErrorMessage)
					.font(.baseStyle(size: 14, weight: .regular))
					.foregroundStyle(.dangerMain)
			}

			noteField
		}
	}

	private var noteField: some View {
		HStack(spacing: 12) {
			Image(systemName: "pencil.line")
				.font(.baseStyle(size: 14, weight: .medium))
				.foregroundStyle(.recordsNeutralIconTint)

			TextField("Add a note...", text: $viewModel.note)
				.font(.baseStyle(size: 14, weight: .regular))
				.foregroundStyle(.addTransactionValueText)
		}
		.padding(.horizontal, 17)
		.padding(.vertical, 15)
		.background(Color(.systemBackground))
		.overlay {
			RoundedRectangle(cornerRadius: 8)
				.stroke(Color.recordsCardBorder, lineWidth: 1)
		}
		.clipShape(RoundedRectangle(cornerRadius: 8))
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
