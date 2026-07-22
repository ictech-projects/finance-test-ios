import Foundation

enum KeychainKey {
	case temporaryToken
    case accessToken
	case FCMToken
}

extension KeychainKey {
	var key: String {
		switch self {
		case .temporaryToken:
			return "projectname.auth.temporary_token"
		case .accessToken:
			return "projectname.auth.access_token"
		case .FCMToken:
			return "projectname.firebase.fcm_token"
		}
	}
}
