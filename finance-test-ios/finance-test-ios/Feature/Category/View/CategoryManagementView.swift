//
//  CategoryManagementView.swift
//  finance-test-ios
//

import SwiftUI

struct CategoryManagementView: View {
	private enum Route: Hashable {
		case add
	}

	@StateObject private var viewModel = CategoryManagementViewModel()
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		VStack(spacing: 0) {
			TopBarView(title: "Category Management", onBackPressed: { dismiss() })
			content
		}
		.background(Color.splashSurface.ignoresSafeArea())
		.navigationBarHidden(true)
		.navigationDestination(for: Route.self) { _ in
			AddCategoryView(initialType: viewModel.selectedType, delegate: viewModel)
		}
		.task {
			await viewModel.onLoad()
		}
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.viewState {
		case .initial, .loading:
			ProgressView()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
		case .error:
			ContentUnavailableView(
				"Couldn't load categories",
				systemImage: "tag",
				description: Text("Please try again later.")
			)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		case .loaded:
			loadedContent
		}
	}

	private var loadedContent: some View {
		VStack(spacing: 0) {
			typeSelector
				.padding(.horizontal, 16)
				.padding(.top, 16)

			ScrollView {
				VStack(alignment: .leading, spacing: 8) {
					Text("Your Categories")
						.font(.baseStyle(size: 18, weight: .bold))
						.foregroundStyle(.neutral100)

					Text("Manage how you organize your transactions.")
						.font(.baseStyle(size: 13, weight: .regular))
						.foregroundStyle(.neutral60)

					VStack(spacing: 8) {
						ForEach(viewModel.rows) { row in
							CategoryRowView(row: row)
						}
					}
					.padding(.top, 8)
				}
				.padding(16)
			}

			NavigationLink(value: Route.add) {
				Label("Add New Category", systemImage: "plus")
					.font(.baseStyle(size: 16, weight: .bold))
					.foregroundStyle(.white)
					.frame(maxWidth: .infinity)
					.frame(height: 56)
					.background(RoundedRectangle(cornerRadius: 12).fill(Color.brandPrimary))
			}
			.buttonStyle(.plain)
			.padding(16)
		}
	}

	private var typeSelector: some View {
		HStack(spacing: 4) {
			TransactionTypeSegment(type: .expense, isSelected: viewModel.selectedType == .expense, onTap: { viewModel.selectedType = .expense })
			TransactionTypeSegment(type: .income, isSelected: viewModel.selectedType == .income, onTap: { viewModel.selectedType = .income })
		}
		.padding(4)
		.background(RoundedRectangle(cornerRadius: 12).fill(Color.moreSectionCardBackground))
	}
}

struct TransactionTypeSegment: View {
	let type: TransactionType
	let isSelected: Bool
	let onTap: () -> Void

	private var label: String {
		type == .expense ? "Expense" : "Income"
	}

	var body: some View {
		Button(action: onTap) {
			Text(label)
				.font(.baseStyle(size: 14, weight: .bold))
				.foregroundStyle(isSelected ? .white : .neutral90)
				.frame(maxWidth: .infinity)
				.padding(.vertical, 10)
				.background(
					RoundedRectangle(cornerRadius: 10)
						.fill(isSelected ? Color.brandPrimary : Color.clear)
				)
		}
		.buttonStyle(.plain)
	}
}

private struct CategoryRowView: View {
	let row: CategoryRow

	private var tintColor: Color {
		row.colorHex.flatMap { Color(hex: $0) } ?? .brandPrimary
	}

	var body: some View {
		HStack(spacing: 12) {
			ZStack {
				Circle()
					.fill(tintColor.opacity(0.15))
					.frame(width: 44, height: 44)

				Image(systemName: row.icon)
					.foregroundStyle(tintColor)
			}

			Text(row.name)
				.font(.baseStyle(size: 15, weight: .semibold))
				.foregroundStyle(.neutral100)

			Spacer()
		}
		.padding(14)
		.background(RoundedRectangle(cornerRadius: 12).fill(Color.moreSectionCardBackground))
	}
}

#Preview {
	NavigationStack {
		CategoryManagementView()
	}
}
