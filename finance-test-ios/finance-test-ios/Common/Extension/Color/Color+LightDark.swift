import SwiftUI

extension Color {
	/// Builds a trait-adaptive color from a light/dark pair, for one-off feature colors that have
	/// no equivalent in the shared `Color.xcassets` catalog — same intent as an asset catalog
	/// colorset's two appearances, without adding a new catalog entry for every feature-scoped tone.
	init(light: Color, dark: Color) {
		self.init(UIColor { traits in
			traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
		})
	}
}
