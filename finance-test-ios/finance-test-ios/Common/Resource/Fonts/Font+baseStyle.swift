import SwiftUI

extension UIFont {
	static func baseStyle(size: CGFloat, weight: Font.Weight) -> UIFont {
		switch weight {
		case .bold:
			UIFont(name: "Inter-Bold", size: size) ?? .systemFont(ofSize: size, weight: .bold)
		case .light:
			UIFont(name: "Inter-Light", size: size) ?? .systemFont(ofSize: size, weight: .light)
		case .regular:
			UIFont(name: "Inter-Regular", size: size) ?? .systemFont(ofSize: size, weight: .regular)
		case .medium:
			UIFont(name: "Inter-Medium", size: size) ?? .systemFont(ofSize: size, weight: .medium)
		default:
			UIFont(name: "Inter-Regular", size: size) ?? .systemFont(ofSize: size, weight: .regular)
		}
	}
}

extension Font {
	static func baseStyle(size: CGFloat, weight: Font.Weight) -> Font {
		switch weight {
		case .bold:
				.custom("Inter-Bold", size: size)
		case .light:
				.custom("Inter-Light", size: size)
		case .regular:
				.custom("Inter-Regular", size: size)
		case .medium:
				.custom("Inter-Medium", size: size)
		default:
				.custom("Inter-Regular", size: size)
		}
	}
}

struct BaseStyleFontPreview: View {
	let sizes: [CGFloat] = [12, 14, 16, 20, 24, 26, 28, 30, 32, 40, 48]
	let weights: [Font.Weight] = [.light, .regular, .medium, .bold]

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 24) {
				
				ForEach(sizes, id: \.self) { size in
					VStack(alignment: .leading, spacing: 12) {
						Text("Size \(Int(size)) pt")
							.font(.headline)
							.padding(.bottom, 4)

						ForEach(weights, id: \.self) { weight in
							Text("Font \(weightName(weight)) • \(Int(size)) pt")
								.font(.baseStyle(size: size, weight: weight))
						}
					}
				}
			}
			.padding()
		}
	}

	private func weightName(_ weight: Font.Weight) -> String {
		switch weight {
		case .light: return "Light"
		case .regular: return "Regular"
		case .medium: return "Medium"
		case .bold: return "Bold"
		default: return "Regular"
		}
	}
}

#Preview {
	BaseStyleFontPreview()
}
