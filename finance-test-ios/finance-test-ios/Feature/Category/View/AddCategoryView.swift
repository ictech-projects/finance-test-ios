//
//  AddCategoryView.swift
//  finance-test-ios
//

import SwiftUI

struct AddCategoryView<Delegate: CategoryMutationDelegate>: View {
	@StateObject private var viewModel: AddCategoryViewModel
	@Environment(\.dismiss) private var dismiss

	init(initialType: TransactionType, delegate: Delegate) {
		_viewModel = StateObject(wrappedValue: AddCategoryViewModel(initialType: initialType, delegate: delegate))
	}

	var body: some View {
		VStack(spacing: 0) {
			TopBarView(title: "Category Management", onBackPressed: { dismiss() })

			ScrollView {
				VStack(alignment: .leading, spacing: 24) {
					nameField
					typeSection
					iconSection
					colorSection
				}
				.padding(16)
			}

			PrimaryButton(size: .large, backgroundColor: .brandPrimary, isDisabled: viewModel.isSaveDisabled, action: {
				Task { await viewModel.save() }
			}) {
				if viewModel.viewState == .saving {
					ProgressView().tint(.white)
				} else {
					Label("Save Category", systemImage: "square.and.arrow.down")
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

	private var nameField: some View {
		TextField("Enter category name", text: $viewModel.name)
			.withTitle(Text("Category Name"), keyboardType: .default)
	}

	private var typeSection: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Type")
				.font(.baseStyle(size: 13, weight: .semibold))
				.foregroundStyle(.neutral90)

			HStack(spacing: 4) {
				TransactionTypeSegment(type: .expense, isSelected: viewModel.selectedType == .expense, onTap: { viewModel.selectedType = .expense })
				TransactionTypeSegment(type: .income, isSelected: viewModel.selectedType == .income, onTap: { viewModel.selectedType = .income })
			}
			.padding(4)
			.background(RoundedRectangle(cornerRadius: 12).fill(Color.moreSectionCardBackground))
		}
	}

	private var iconSection: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Icon")
				.font(.baseStyle(size: 13, weight: .semibold))
				.foregroundStyle(.neutral90)

			LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
				ForEach(AddCategoryViewModel.iconOptions, id: \.self) { icon in
					Button(action: { viewModel.selectedIcon = icon }) {
						Image(systemName: icon)
							.foregroundStyle(viewModel.selectedIcon == icon ? .white : .neutral70)
							.frame(width: 40, height: 40)
							.background(
								Circle().fill(viewModel.selectedIcon == icon ? Color.brandPrimary : Color.moreSectionCardBackground)
							)
					}
					.buttonStyle(.plain)
				}
			}
		}
	}

	private var colorSection: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Brand Color")
				.font(.baseStyle(size: 13, weight: .semibold))
				.foregroundStyle(.neutral90)

			LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
				ForEach(AddCategoryViewModel.colorOptions, id: \.self) { hex in
					Button(action: { viewModel.selectedColorHex = hex }) {
						Circle()
							.fill(Color(hex: hex) ?? .brandPrimary)
							.frame(width: 40, height: 40)
							.overlay(
								Circle().stroke(Color.neutral90, lineWidth: viewModel.selectedColorHex == hex ? 2 : 0)
									.padding(-3)
							)
					}
					.buttonStyle(.plain)
				}
			}
		}
	}
}

private final class PreviewCategoryMutationDelegate: CategoryMutationDelegate {
	func categoryDidChange() {}
}

#Preview {
	NavigationStack {
		AddCategoryView(initialType: .expense, delegate: PreviewCategoryMutationDelegate())
	}
}
