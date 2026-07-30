//
//  AddTransactionNumericKeypad.swift
//  finance-test-ios
//

import SwiftUI

/// Calculator-style keypad for entering the transaction amount — there is no system keyboard
/// on this screen, per the Figma design.
struct AddTransactionNumericKeypad: View {
	let onKeyTapped: (NumericKeypadKey) -> Void

	private static let rows: [[NumericKeypadKey]] = [
		[.digit(1), .digit(2), .digit(3)],
		[.digit(4), .digit(5), .digit(6)],
		[.digit(7), .digit(8), .digit(9)],
		[.decimalPoint, .digit(0), .delete]
	]

	var body: some View {
		VStack(spacing: 4) {
			ForEach(Array(Self.rows.enumerated()), id: \.offset) { _, row in
				HStack(spacing: 4) {
					ForEach(row, id: \.self) { key in
						keyButton(key)
					}
				}
			}
		}
		.padding(8)
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(Color.recordsNeutralIconBackground.opacity(0.8))
		)
	}

	@ViewBuilder
	private func keyButton(_ key: NumericKeypadKey) -> some View {
		Button {
			onKeyTapped(key)
		} label: {
			Group {
				switch key {
				case .digit(let value):
					Text("\(value)")
				case .decimalPoint:
					Text(".")
				case .delete:
					Image(systemName: "delete.left")
				}
			}
			.font(.baseStyle(size: 22, weight: .medium))
			.foregroundStyle(.addTransactionValueText)
			.frame(maxWidth: .infinity)
			.frame(height: 56)
			.background(
				RoundedRectangle(cornerRadius: 8)
					.fill(Color.recordsCardBackground)
			)
		}
		.buttonStyle(PressableKeyStyle())
	}
}

private struct PressableKeyStyle: ButtonStyle {
	func makeBody(configuration: ButtonStyleConfiguration) -> some View {
		configuration.label
			.opacity(configuration.isPressed ? 0.6 : 1)
			.animation(.easeOut(duration: 0.1), value: configuration.isPressed)
	}
}

#Preview {
	AddTransactionNumericKeypad(onKeyTapped: { _ in })
		.padding()
		.background(Color.neutral20)
}
