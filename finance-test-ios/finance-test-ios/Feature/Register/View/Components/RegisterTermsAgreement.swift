//
//  RegisterTermsAgreement.swift
//  finance-test-ios
//

import SwiftUI

struct RegisterTermsAgreement: View {
	@Binding var isAgreed: Bool
	var errorMessage: String? = nil
	let onToggle: () -> Void
	let onTermsTapped: () -> Void
	let onPrivacyPolicyTapped: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack(alignment: .top, spacing: 12) {
				Button(action: onToggle) {
					checkbox
				}
				.buttonStyle(.plain)
				.accessibilityLabel(Text("Agree to Terms & Conditions and Privacy Policy"))

				Text(termsAttributedText)
					.environment(\.openURL, OpenURLAction { url in
						switch url.absoluteString {
						case Self.termsURL.absoluteString:
							onTermsTapped()
						case Self.privacyPolicyURL.absoluteString:
							onPrivacyPolicyTapped()
						default:
							break
						}
						return .handled
					})
			}

			if let errorMessage {
				Text(errorMessage)
					.font(.baseStyle(size: 14, weight: .regular))
					.foregroundStyle(.dangerMain)
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}

	private var checkbox: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 3)
				.fill(isAgreed ? Color.brandPrimary : Color.clear)

			RoundedRectangle(cornerRadius: 3)
				.stroke(strokeColor, lineWidth: 1)

			if isAgreed {
				Image(systemName: "checkmark")
					.resizable()
					.scaledToFit()
					.fontWeight(.bold)
					.frame(width: 9, height: 9)
					.foregroundStyle(.white)
			}
		}
		.frame(width: 16, height: 16)
		.padding(.top, 4)
	}

	private var strokeColor: Color {
		if errorMessage != nil {
			.dangerMain
		} else if isAgreed {
			.brandPrimary
		} else {
			.neutral70
		}
	}

	private static let termsURL = URL(string: "app://terms")!
	private static let privacyPolicyURL = URL(string: "app://privacy")!

	private var termsAttributedText: AttributedString {
		var agree = AttributedString("I agree to the ")
		agree.font = .baseStyle(size: 14, weight: .regular)
		agree.foregroundColor = .neutral90

		var terms = AttributedString("Terms & Conditions")
		terms.font = .baseStyle(size: 14, weight: .medium)
		terms.foregroundColor = .brandPrimary
		terms.link = Self.termsURL

		var and = AttributedString(" and ")
		and.font = .baseStyle(size: 14, weight: .regular)
		and.foregroundColor = .neutral90

		var privacy = AttributedString("Privacy Policy")
		privacy.font = .baseStyle(size: 14, weight: .medium)
		privacy.foregroundColor = .brandPrimary
		privacy.link = Self.privacyPolicyURL

		var period = AttributedString(".")
		period.font = .baseStyle(size: 14, weight: .regular)
		period.foregroundColor = .neutral90

		return agree + terms + and + privacy + period
	}
}

#Preview {
	@Previewable @State var isAgreed = false

	VStack(alignment: .leading, spacing: 24) {
		RegisterTermsAgreement(
			isAgreed: $isAgreed,
			onToggle: { isAgreed.toggle() },
			onTermsTapped: {},
			onPrivacyPolicyTapped: {}
		)

		RegisterTermsAgreement(
			isAgreed: $isAgreed,
			errorMessage: "Please agree to the Terms & Conditions and Privacy Policy to continue.",
			onToggle: { isAgreed.toggle() },
			onTermsTapped: {},
			onPrivacyPolicyTapped: {}
		)
	}
	.padding()
}
