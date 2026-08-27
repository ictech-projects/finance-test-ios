//
//  LaunchScreenView.swift
//  IosBaseProject
//
//  Created by Arifin Firdaus on 27/01/26.
//

import SwiftUI

/// The app's actual root view. Shows a brief splash (the OS-level static Launch Screen already
/// covers the true cold-start instant — see `INFOPLIST_KEY_UILaunchScreen_BackgroundColorName`),
/// runs the session check, then switches its own body to `RootTabView`/`LoginView` and keeps
/// reacting to `SessionStore` afterwards, so a later logout (manual or 401-triggered) routes
/// back to `LoginView` without relaunching the app.
struct LaunchScreenView: View {

	@StateObject private var viewModel = LaunchScreenViewModel()
	@StateObject private var displayCurrency = DisplayCurrencyDefaultStore.shared

	var body: some View {
		Group {
			if viewModel.isLaunching {
				Color.splashSurface
					.ignoresSafeArea()
					.overlay {
						VStack(spacing: 16) {
							Image(.mainIcon)
								.resizable()
								.scaledToFit()
								.frame(width: 49, height: 54)
								.shadow(color: .cardShadow, radius: 4, x: 0, y: 2)

							Text("SpendWise")
								.font(.baseStyle(size: 28, weight: .bold))
								.foregroundStyle(.brandPrimary)

							ProgressView()
								.padding(.top, 24)
						}
					}
			} else if viewModel.isLoggedIn {
				RootTabView()
			} else {
				// `AuthFlowView` wraps Login + Register navigation. Its own `onAuthenticated`
				// callback is a no-op here — the actual root swap to `RootTabView` is already
				// driven reactively by `viewModel.isLoggedIn` above (which flips as soon as
				// `AuthDefaultRepository.login()`/`.register()` mark the shared session store
				// logged in), not by this callback.
				AuthFlowView(onAuthenticated: {})
			}
		}
		.environmentObject(displayCurrency)
		.task { await viewModel.onAppear() }
		// The anchor currency is per-user, so it's resolved once the session is known and again
		// after any later login — a logged-out launch has nothing to read.
		.task(id: viewModel.isLoggedIn) {
			guard viewModel.isLoggedIn else { return }
			await displayCurrency.refresh()
		}
	}
}

#Preview {
	LaunchScreenView()
}
