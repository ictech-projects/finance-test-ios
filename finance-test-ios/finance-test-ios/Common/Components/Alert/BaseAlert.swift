import SwiftUI

struct BaseAlert: ViewModifier {
	@Binding var isPresented: Bool
	let type: AlertType
	let title: String
	let message: String
	let confirmButtonColor: Color
	let confirmLabel: Text
	let confirmIcon: String?
	let cancelLabel: Text?
	let confirmAction: () -> Void
	let cancelAction: (() -> Void)?

	init(
		isPresented: Binding<Bool>,
		type: AlertType,
		title: String,
		message: String,
		confirmButtonColor: Color = .brandPrimary,
		confirmLabel: Text,
		confirmIcon: String? = nil,
		cancelLabel: Text? = nil,
		confirmAction: @escaping () -> Void,
		cancelAction: (() -> Void)? = nil
	) {
		self._isPresented = isPresented
		self.type = type
		self.title = title
		self.message = message
		self.confirmButtonColor = confirmButtonColor
		self.confirmLabel = confirmLabel
		self.confirmIcon = confirmIcon
		self.cancelLabel = cancelLabel
		self.confirmAction = confirmAction
		self.cancelAction = cancelAction
	}

	func body(content: Content) -> some View {
		content.overlay {
			if isPresented {
				ZStack {
					Rectangle()
						.fill(.thinMaterial)

					Color.black.opacity(0.25)
				}
				.ignoresSafeArea()
				.transition(.opacity)

				VStack(spacing: 24) {
					ZStack {
						Circle()
							.fill(type.badgeColor)
							.frame(width: 80, height: 80)

						Image(systemName: type.iconSystemName)
							.font(.system(size: 32, weight: .bold))
							.foregroundStyle(type.iconColor)
					}

					VStack(spacing: 8) {
						Text(title)
							.font(.baseStyle(size: 22, weight: .bold))
							.foregroundStyle(.neutral100)
							.multilineTextAlignment(.center)

						Text(message)
							.font(.baseStyle(size: 14, weight: .regular))
							.foregroundStyle(.neutral70)
							.multilineTextAlignment(.center)
					}

					VStack(spacing: 12) {
						PrimaryButton(
							size: .large,
							backgroundColor: confirmButtonColor,
							cornerRadius: 999,
							action: confirmAction
						) {
							HStack(spacing: 8) {
								if let confirmIcon {
									Image(systemName: confirmIcon)
								}
								confirmLabel
							}
						}

						if let cancelLabel, let cancelAction {
							Button(action: cancelAction) {
								cancelLabel
									.font(.baseStyle(size: 14, weight: .medium))
									.foregroundStyle(confirmButtonColor)
							}
						}
					}
				}
				.padding(24)
				.background(Color(.systemBackground))
				.clipShape(RoundedRectangle(cornerRadius: 28))
				.padding(24)
				.transition(.scale(scale: 0.9).combined(with: .opacity))
			}
		}
		.animation(.spring(response: 0.35, dampingFraction: 0.85), value: isPresented)
	}
}

extension View {
	func baseAlert(
		isPresented: Binding<Bool>,
		type: AlertType,
		title: String,
		message: String,
		confirmButtonColor: Color = .brandPrimary,
		confirmLabel: Text,
		confirmIcon: String? = nil,
		cancelLabel: Text? = nil,
		confirmAction: @escaping () -> Void,
		cancelAction: (() -> Void)? = nil
	) -> some View {
		modifier(
			BaseAlert(
				isPresented: isPresented,
				type: type,
				title: title,
				message: message,
				confirmButtonColor: confirmButtonColor,
				confirmLabel: confirmLabel,
				confirmIcon: confirmIcon,
				cancelLabel: cancelLabel,
				confirmAction: confirmAction,
				cancelAction: cancelAction
			)
		)
	}
}

#Preview("Error") {
	Color.neutral20
		.ignoresSafeArea()
		.baseAlert(
			isPresented: .constant(true),
			type: .error,
			title: "Something Went Wrong",
			message: "We couldn't complete the request. Please check your connection or try again.",
			confirmLabel: Text("Try Again"),
			confirmIcon: "arrow.clockwise",
			cancelLabel: Text("Cancel"),
			confirmAction: {},
			cancelAction: {}
		)
}

#Preview("Success") {
	Color.neutral20
		.ignoresSafeArea()
		.baseAlert(
			isPresented: .constant(true),
			type: .success,
			title: "Action Successful",
			message: "Your changes have been saved with precision.",
			confirmLabel: Text("Done"),
			confirmAction: {}
		)
}

#Preview("Warning") {
	Color.neutral20
		.ignoresSafeArea()
		.baseAlert(
			isPresented: .constant(true),
			type: .warning,
			title: "Unsaved Changes",
			message: "You have unsaved changes that will be lost if you leave this screen.",
			confirmLabel: Text("Leave"),
			cancelLabel: Text("Stay"),
			confirmAction: {},
			cancelAction: {}
		)
}

#Preview("Info") {
	Color.neutral20
		.ignoresSafeArea()
		.baseAlert(
			isPresented: .constant(true),
			type: .info,
			title: "New Feature Available",
			message: "You can now sync currencies automatically from Settings.",
			confirmLabel: Text("Got It"),
			confirmAction: {}
		)
}
