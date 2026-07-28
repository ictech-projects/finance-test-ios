import Foundation

enum BaseEnvironment: String {
	case production = "Production"
	case development = "Development"
	
	var baseURL: String {
		switch self {
		case .production:
			"https://wallet.birchlabs.tech/api/v1"
		case .development:
			"https://wallet.birchlabs.tech/api/v1"
		}
	}
}
