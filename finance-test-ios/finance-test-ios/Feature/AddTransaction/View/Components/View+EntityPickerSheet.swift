//
//  View+EntityPickerSheet.swift
//  finance-test-ios
//

import SwiftUI

/// Bottom-sheet picker for a list of interchangeable items (accounts, categories, …). Follows the
/// same dimmed-backdrop + overlay pattern as `CurrencySelectionDialogModifier`, anchored to the
/// bottom of the screen instead of centered.
struct EntityPickerSheetModifier<Item: Hashable, RowContent: View>: ViewModifier {
	@Binding var isPresented: Bool
	let title: String
	let items: [Item]
	let selection: Item?
	let onSelect: (Item) -> Void
	@ViewBuilder let rowContent: (Item, Bool) -> RowContent

	func body(content: Content) -> some View {
		content.overlay {
			if isPresented {
				Color.black.opacity(0.4)
					.ignoresSafeArea()
					.transition(.opacity)
					.onTapGesture { isPresented = false }

				VStack {
					Spacer()

					EntityPickerSheetView(
						title: title, items: items, selection: selection,
						onSelect: onSelect, rowContent: rowContent
					)
				}
				.transition(.move(edge: .bottom).combined(with: .opacity))
			}
		}
		.animation(.spring(response: 0.35, dampingFraction: 0.85), value: isPresented)
	}
}

private struct EntityPickerSheetView<Item: Hashable, RowContent: View>: View {
	let title: String
	let items: [Item]
	let selection: Item?
	let onSelect: (Item) -> Void
	@ViewBuilder let rowContent: (Item, Bool) -> RowContent

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Capsule()
				.fill(Color.neutral50)
				.frame(width: 36, height: 4)
				.frame(maxWidth: .infinity, alignment: .center)

			Text(title)
				.font(.baseStyle(size: 18, weight: .bold))
				.foregroundStyle(.neutral100)

			if items.isEmpty {
				Text("Nothing to select yet.")
					.font(.baseStyle(size: 14, weight: .regular))
					.foregroundStyle(.neutral60)
					.frame(maxWidth: .infinity)
					.padding(.vertical, 24)
			} else {
				ScrollView {
					VStack(spacing: 4) {
						ForEach(items, id: \.self) { item in
							Button {
								onSelect(item)
							} label: {
								rowContent(item, item == selection)
							}
						}
					}
				}
				.frame(maxHeight: 360)
			}
		}
		.padding(20)
		.padding(.bottom, 12)
		.background(Color(.systemBackground))
		.clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
	}
}

extension View {
	func entityPickerSheet<Item: Hashable, RowContent: View>(
		isPresented: Binding<Bool>,
		title: String,
		items: [Item],
		selection: Item?,
		onSelect: @escaping (Item) -> Void,
		@ViewBuilder rowContent: @escaping (Item, Bool) -> RowContent
	) -> some View {
		modifier(
			EntityPickerSheetModifier(
				isPresented: isPresented, title: title, items: items,
				selection: selection, onSelect: onSelect, rowContent: rowContent
			)
		)
	}
}

#Preview {
	struct PreviewHost: View {
		@State private var isPresented = true
		@State private var selection: String? = "Cash"

		var body: some View {
			Color.neutral20.ignoresSafeArea()
				.entityPickerSheet(
					isPresented: $isPresented,
					title: "Select Account",
					items: ["Cash", "Main Bank", "Credit Card"],
					selection: selection,
					onSelect: { selection = $0 }
				) { item, isSelected in
					HStack {
						Text(item)
							.foregroundStyle(.neutral90)
						Spacer()
						if isSelected {
							Image(systemName: "checkmark")
								.foregroundStyle(.brandPrimary)
						}
					}
					.padding(12)
				}
		}
	}

	return PreviewHost()
}
