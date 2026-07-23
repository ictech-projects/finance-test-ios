import SwiftUI

extension UIFont {
	static func baseStyle(size: CGFloat, weight: Font.Weight) -> UIFont {
		switch weight {
		case .bold:
			UIFont(name: "TODO:<FONT_NAME>", size: size) ?? .systemFont(ofSize: size, weight: .bold)
		case .light:
			UIFont(name: "TODO:<FONT_NAME>", size: size) ?? .systemFont(ofSize: size, weight: .light)
		case .regular:
			UIFont(name: "TODO:<FONT_NAME>", size: size) ?? .systemFont(ofSize: size, weight: .regular)
		case .medium:
			UIFont(name: "TODO:<FONT_NAME>", size: size) ?? .systemFont(ofSize: size, weight: .medium)
		default:
			UIFont(name: "TODO:<FONT_NAME>", size: size) ?? .systemFont(ofSize: size, weight: .regular)
		}
	}
}

extension Font {
	static func baseStyle(size: CGFloat, weight: Font.Weight) -> Font {
		switch weight {
		case .bold:
				.custom("TODO:<FONT_NAME>", size: size)
		case .light:
				.custom("TODO:<FONT_NAME>", size: size)
		case .regular:
				.custom("TODO:<FONT_NAME>", size: size)
		case .medium:
				.custom("TODO:<FONT_NAME>", size: size)
		default:
				.custom("TODO:<FONT_NAME>", size: size)
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
