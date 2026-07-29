import Foundation
import SwiftUI

enum AlertType {
	case success
	case error
	case warning
	case info
}

extension AlertType {
	var iconSystemName: String {
		switch self {
		case .success:
			"checkmark"
		case .error, .warning:
			"exclamationmark.triangle.fill"
		case .info:
			"info"
		}
	}

	var iconColor: Color {
		switch self {
		case .success:
			.successMain
		case .error:
			.dangerMain
		case .warning:
			.warningMain
		case .info:
			.infoMain
		}
	}

	var badgeColor: Color {
		switch self {
		case .success:
			.successSurface
		case .error:
			.dangerSurface
		case .warning:
			.warningSurface
		case .info:
			.infoSurface
		}
	}
}
