//
//  RecordsView.swift
//  finance-test-ios
//

import SwiftUI

struct RecordsView: View {
	@StateObject private var viewModel = RecordsViewModel()

	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				header
				content
			}
			.background(Color.neutral20.ignoresSafeArea())
			.navigationBarHidden(true)
		}
		.task {
			await viewModel.onLoad()
		}
		.sheet(isPresented: $viewModel.isAddTransactionPresented) {
			AddTransactionView(delegate: viewModel)
		}
	}

	private var header: some View {
		ZStack {
			Text("Records")
				.font(.baseStyle(size: 24, weight: .bold))
				.foregroundStyle(.brandPrimary)

			HStack {
				Spacer()

				Button {
					viewModel.presentAddTransaction()
				} label: {
					Image(systemName: "plus.circle.fill")
						.font(.baseStyle(size: 22, weight: .semibold))
						.foregroundStyle(.brandPrimary)
				}
			}
			.padding(.trailing, 16)
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 16)
		.background(Color.neutral10)
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
