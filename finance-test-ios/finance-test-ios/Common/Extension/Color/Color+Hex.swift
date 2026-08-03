import SwiftUI

extension Color {
	/// Parses a `"#RRGGBB"` (or `"RRGGBB"`) hex string, as returned by the backend for
	/// account/category swatch colors. Returns `nil` for anything else.
	init?(hex: String) {
		var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
		if sanitized.hasPrefix("#") {
			sanitized.removeFirst()
		}

		guard sanitized.count == 6, let value = UInt32(sanitized, radix: 16) else {
			return nil
		}

		let red = Double((value >> 16) & 0xFF) / 255
		let green = Double((value >> 8) & 0xFF) / 255
		let blue = Double(value & 0xFF) / 255

		self.init(red: red, green: green, blue: blue)
	}
}
