//
//  IosBaseProjectApp.swift
//  IosBaseProject
//
//  Created by Arifin Firdaus on 27/01/26.
//

import SwiftUI
import IQKeyboardManagerSwift

@main
struct IosBaseProjectApp: App {

	@StateObject private var appearanceManager = AppearanceManager()

	init() {
		tabBarAdjustment()
	}

	var body: some Scene {
		WindowGroup {
			LaunchScreenView()
				.environmentObject(appearanceManager)
				.preferredColorScheme(appearanceManager.mode.colorScheme)
		}
	}
}

extension IosBaseProjectApp {
	
	private func tabBarAdjustment() {
		let appearance = UITabBarAppearance()
		
		appearance.configureWithOpaqueBackground()
		appearance.shadowColor = .clear
		appearance.shadowImage = UIImage()
		
		let normalFont = UIFont.baseStyle(size: 12, weight: .medium)
		let selectedFont = UIFont.baseStyle(size: 12, weight: .bold)
		
		appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
			.font: normalFont,
			.foregroundColor: UIColor(resource: .neutral90),
		]
		
		appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
			.font: selectedFont,
			.foregroundColor: UIColor(resource: .brandPrimary)
		]
		
		UITabBar.appearance().standardAppearance = appearance
		UITabBar.appearance().scrollEdgeAppearance = appearance
	}
}

class AppDelegate: NSObject, UIApplicationDelegate {
	// TODO: Enable push notification setup when FCM configuration is ready
	// let authRepo = AuthenticationDefaultRepository()
	
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		IQKeyboardManager.shared.isEnabled = true
		IQKeyboardManager.shared.resignOnTouchOutside = true
		
		// TODO: Enable push notification setup when FCM configuration is ready
		// configurePushNotification()
		
		return true
	}
	
	//	 TODO: Enable push notification setup when FCM configuration is ready
	//	 private func configurePushNotification() {
	//	     FirebaseApp.configure()
	//	     Messaging.messaging().delegate = self
	//	     UNUserNotificationCenter.current().delegate = self
	//	     Task {
	//	         try? await requestNotificationPermission()
	//	     }
	//	 }
	//
	//	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
	//		Messaging.messaging().apnsToken = deviceToken
	//	}
	//
	//	@MainActor
	//	func requestNotificationPermission() async throws {
	//		let granted = try await UNUserNotificationCenter.current()
	//			.requestAuthorization(options: [.alert, .sound, .badge])
	//
	//		if granted {
	//			UIApplication.shared.registerForRemoteNotifications()
	//
	//			guard let fcm = Messaging.messaging().fcmToken else { return }
	//
	//			authRepo.storeToken(from: fcm, with: KeychainKey.FCMToken.key)
	//		}
	//	}
}

// TODO: Enable push notification setup when FCM configuration is ready
// extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
//	func userNotificationCenter(
//		_ center: UNUserNotificationCenter,
//		willPresent notification: UNNotification,
//		withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
//	) {
//		completionHandler([.banner, .sound, .badge])
//	}
//
//	func userNotificationCenter(
//		_ center: UNUserNotificationCenter,
//		didReceive response: UNNotificationResponse,
//		withCompletionHandler completionHandler: @escaping () -> Void
//	) {
//		let userInfo = response.notification.request.content.userInfo
//
//		if let notification = userInfo["notification_id"] as? String {
//			NotificationCenter.default.post(name: Notification.Name("NavigateFromPush"), object: nil, userInfo: ["notification_id": notification])
//		}
//
//		completionHandler()
//	}
//
//	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//		if let fcmToken {
//			authRepo.storeToken(from: fcmToken, with: KeychainKey.FCMToken.key)
//		}
//	}
//}
