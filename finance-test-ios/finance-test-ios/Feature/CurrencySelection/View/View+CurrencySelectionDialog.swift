//
//  View+CurrencySelectionDialog.swift
//  finance-test-ios
//

import SwiftUI

struct CurrencySelectionDialogModifier<Delegate: CurrencySelectionDelegate>: ViewModifier {
	@Binding var isPresented: Bool
	let delegate: Delegate

	func body(content: Content) -> some View {
		content.overlay {
			if isPresented {
				Color.black
					.opacity(0.75)
					.ignoresSafeArea()

				CurrencySelectionDialogView(delegate: delegate)
					.padding(24)
			}
		}
	}
}

extension View {
	func currencySelectionDialog(
		isPresented: Binding<Bool>,
		delegate: some CurrencySelectionDelegate
	) -> some View {
		modifier(CurrencySelectionDialogModifier(isPresented: isPresented, delegate: delegate))
	}
}
