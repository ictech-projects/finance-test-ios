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

	var body: some View {
		Group {
			if viewModel.isLaunching {
				Color.splashSurface
					.ignoresSafeArea()
					.overlay { ProgressView() }
			} else if viewModel.isLoggedIn {
				RootTabView()
			} else {
				LoginView()
			}
		}
		.task { await viewModel.onAppear() }
	}
}

#Preview {
	LaunchScreenView()
}
