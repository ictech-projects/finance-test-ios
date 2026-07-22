import SwiftUI

struct MainClockButton: View {
	@Binding var type: ClockedType
	let geo: GeometryProxy
	let action: () -> Void
	
	@GestureState private var isPressed = false
	@State private var animateRelease = false
	
	var body: some View {
		ZStack {
			Circle()
				.fill(Color.neutral30)
				.scaledToFit()
				.frame(height: geo.size.height/3.5)
				.overlay(
					Circle()
						.stroke(.whiteEEEEEE.opacity(type == .disabled ? 1 : 0), lineWidth: 4)
						.blur(radius: 6)
						.offset(y: 2)
						.mask(
							Circle()
								.fill(LinearGradient(
									colors: [.black, .clear],
									startPoint: .bottom,
									endPoint: .top
								))
						)
				)
			
			Button {
				action()
				withAnimation(.bouncy) {
					animateRelease = true
				}
				Task {
					try? await Task.sleep(for: .seconds(0.15))
					withAnimation(.bouncy) {
						animateRelease = false
					}
				}
			} label: {
				ZStack {
					if let outerImage {
						outerImage
							.resizable()
							.scaledToFit()
							.frame(height: geo.size.height/4)
							.shadow(
								color: type == .disabled ? .grayF1F1F1 : .clear,
								radius: type == .disabled ? 6 : 0,
								x: 0,
								y: type == .disabled ? 4 : 0
							)
					}
					
					if let innerImage {
						innerImage
							.resizable()
							.scaledToFit()
							.frame(height: geo.size.height/4.5)
					}
					
					VStack(spacing: 8) {
						buttonIcon
							.font(.system(size: 24, weight: .bold))
							.foregroundStyle(.white)
						
						labelTitleText
							.font(.baseStyle(size: 12, weight: .medium))
							.foregroundStyle(labelTitleColor)
					}
				}
			}
			.scaleEffect(scale)
			.disabled(type == .disabled)
			.simultaneousGesture(
				DragGesture(minimumDistance: 0)
					.updating($isPressed) { _, state, _ in
						withAnimation(.bouncy) {
							state = true
						}
					}
			)
			.buttonStyle(.plain)
		}
	}
}

enum ClockedType {
	case clockIn
	case clockOut
	case disabled
}

private extension MainClockButton {
	
	var scale: CGFloat {
		if type == .disabled { return 1 } // no bounce
		
		if isPressed { return 0.92 } // pressed down
		
		if animateRelease {
			return 1.05 // bounce up
		}
		
		return 1 // normal
	}
}

private extension MainClockButton {
	
	private var labelTitleColor: Color {
		switch type {
		case .clockIn, .clockOut: .neutral10
		case .disabled: .neutral50
		}
	}
	
	private var buttonIcon: Image {
		switch type {
		case .clockIn:
			Image(.tapToCheckIn)
		case .clockOut:
			Image(.tapToCheckOut)
		case .disabled:
			Image(.unavailable)
		}
	}
	
	private var outerImage: Image? {
		switch type {
		case .clockIn:
			Image(.clockInOuterCirleButtonBackground)
		case .clockOut:
			Image(.clockOutOuterCircleButtonBackground)
		case .disabled:
			Image(.disabledOuterCircleButtonBackground)
		}
	}
	
	private var innerImage: Image? {
		switch type {
		case .clockIn:
			Image(.clockInInnerCircleButtonBackground)
		case .clockOut:
			Image(.clockOutInnerCircleButtonBackground)
		case .disabled:
			nil // disabled has only one circle
		}
	}
	
	private var labelTitleText: Text {
		switch type {
		case .clockIn: Text("Tap to Check in")
		case .clockOut: Text("Tap to Check Out")
		case .disabled: Text("unavailable")
		}
	}
}

#Preview {
	GeometryReader { geo in
		VStack(spacing: 30) {
			MainClockButton(type: .constant(.clockIn), geo: geo, action: {})
			MainClockButton(type: .constant(.clockOut), geo: geo, action: {})
			MainClockButton(type: .constant(.disabled), geo: geo, action: {})
		}
	}
	.padding()
	.background(Color.white)
}

#Preview {
	GeometryReader { geo in
		MainClockButton(type: .constant(.disabled), geo: geo, action: {})
	}
		.padding()
		.background(Color.white)
}
