//
//  AppearanceSettingView.swift
//  finance-test-ios
//

import SwiftUI

struct AppearanceSettingView: View {
	@EnvironmentObject private var appearanceManager: AppearanceManager
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		VStack(spacing: 0) {
			TopBarView(title: "Appearance", onBackPressed: { dismiss() })

			ScrollView {
				VStack(alignment: .leading, spacing: 8) {
					Text("Choose how the app looks. \"System\" follows your device's setting.")
						.font(.baseStyle(size: 13, weight: .regular))
						.foregroundStyle(.neutral60)
						.padding(.bottom, 8)

					VStack(spacing: 0) {
						ForEach(Array(AppearanceMode.allCases.enumerated()), id: \.element) { index, mode in
							if index > 0 {
								Rectangle()
									.fill(.moreHairline.opacity(0.2))
									.frame(height: 1)
							}

							AppearanceModeRow(
								mode: mode,
								isSelected: appearanceManager.mode == mode,
								onTap: { appearanceManager.mode = mode }
							)
						}
					}
					.background(RoundedRectangle(cornerRadius: 12).fill(Color.moreSectionCardBackground))
				}
				.padding(16)
			}
		}
		.background(Color.splashSurface.ignoresSafeArea())
		.navigationBarHidden(true)
	}
}

private struct AppearanceModeRow: View {
	let mode: AppearanceMode
	let isSelected: Bool
	let onTap: () -> Void

	private var icon: String {
		switch mode {
		case .system: "circle.lefthalf.filled"
		case .light: "sun.max.fill"
		case .dark: "moon.fill"
		}
	}

	var body: some View {
		Button(action: onTap) {
			HStack(spacing: 12) {
				Image(systemName: icon)
					.foregroundStyle(.brandPrimary)
					.frame(width: 24)

				Text(mode.label)
					.font(.baseStyle(size: 15, weight: .semibold))
					.foregroundStyle(.neutral100)

				Spacer()

				if isSelected {
					Image(systemName: "checkmark")
						.font(.system(size: 14, weight: .bold))
						.foregroundStyle(.brandPrimary)
				}
			}
			.padding(14)
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
	}
}

#Preview {
	NavigationStack {
		AppearanceSettingView()
			.environmentObject(AppearanceManager())
	}
}
