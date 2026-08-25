//
//  RecordsView.swift
//  finance-test-ios
//

import SwiftUI

struct RecordsView: View {
	@StateObject private var viewModel: RecordsViewModel
	@Environment(\.dismiss) private var dismiss

	/// `false` (default) when this is the "Records" tab root — owns its own `NavigationStack`.
	/// `true` when pushed as a destination from another screen's `NavigationStack` (e.g. tapping
	/// a category in Reports) — nesting a second `NavigationStack` there would swallow the back
	/// button, so this renders bare content plus a `TopBarView` back button using `dismiss()`.
	private let isPushedDestination: Bool

	init(initialCategoryFilter: String? = nil, isPushedDestination: Bool = false) {
		_viewModel = StateObject(wrappedValue: RecordsViewModel(categoryFilter: initialCategoryFilter))
		self.isPushedDestination = isPushedDestination
	}

	var body: some View {
		Group {
			if isPushedDestination {
				screenContent
			} else {
				NavigationStack {
					screenContent
				}
			}
		}
		.task {
			await viewModel.onLoad()
		}
		.sheet(isPresented: $viewModel.isAddTransactionPresented) {
			AddTransactionView(delegate: viewModel)
		}
	}

	private var screenContent: some View {
		ZStack(alignment: .bottomTrailing) {
			VStack(spacing: 0) {
				header
				content
			}

			addTransactionFAB
				.padding(.trailing, 24)
				.padding(.bottom, 24)
		}
		.background(Color.neutral20.ignoresSafeArea())
		.navigationBarHidden(true)
	}

	@ViewBuilder
	private var header: some View {
		if isPushedDestination {
			TopBarView(title: "Records", onBackPressed: { dismiss() })
		} else {
			Text("Records")
				.font(.baseStyle(size: 24, weight: .bold))
				.foregroundStyle(.brandPrimary)
				.frame(maxWidth: .infinity)
				.padding(.vertical, 16)
				.background(Color.neutral10)
		}
	}

	/// Matches Figma's "Button - FAB: Add Transaction" — a floating, icon+label pill, not a bare
	/// plus icon inline in the header.
	private var addTransactionFAB: some View {
		Button {
			viewModel.presentAddTransaction()
		} label: {
			HStack(spacing: 12) {
				Image(systemName: "plus")
					.font(.baseStyle(size: 14, weight: .bold))

				Text("Add Transaction")
					.font(.baseStyle(size: 14, weight: .semibold))
			}
			.foregroundStyle(.addTransactionFabText)
			.padding(.horizontal, 24)
			.frame(height: 56)
			.background(
				RoundedRectangle(cornerRadius: 16)
					.fill(Color.addTransactionFabBackground)
			)
			.shadow(color: .black.opacity(0.15), radius: 8, y: 4)
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
				"Couldn't load records",
				systemImage: "exclamationmark.triangle",
				description: Text("Please try again later.")
			)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		case .loaded:
			loadedContent
		}
	}

	private var loadedContent: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 24) {
				RecordsFilterBar(
					typeFilter: $viewModel.typeFilter,
					categoryFilter: $viewModel.categoryFilter,
					accountFilter: $viewModel.accountFilter,
					availableCategoryNames: viewModel.availableCategoryNames,
					availableAccountNames: viewModel.availableAccountNames
				)
				.staggeredAppear(index: 0)

				if viewModel.sections.isEmpty {
					ContentUnavailableView(
						"No Records",
						systemImage: "tray",
						description: Text("Transactions matching these filters will appear here.")
					)
					.frame(maxWidth: .infinity)
					.padding(.top, 40)
				} else {
					ForEach(indexedSections, id: \.section.id) { entry in
						RecordsSectionView(section: entry.section, startIndex: entry.startIndex)
					}
				}
			}
			.padding(16)
			.animation(.easeInOut(duration: 0.25), value: viewModel.sections)
		}
	}

	private var indexedSections: [(section: RecordsSection, startIndex: Int)] {
		var index = 0
		return viewModel.sections.map { section in
			let start = index
			index += section.items.count
			return (section, start)
		}
	}
}

#Preview {
	RecordsView()
}
