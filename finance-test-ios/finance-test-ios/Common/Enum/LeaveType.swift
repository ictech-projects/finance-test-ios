import Foundation

enum LeaveTypes: Int, CaseIterable {
	case annual = 1
	case special = 2
	case sick = 3
	case unpaid = 4
	
	var name: String {
		switch self {
		case .annual:
			"Annual Leave"
		case .special:
			"Special Leave"
		case .sick:
			"Sick Leave"
		case .unpaid:
			"Unpaid Leave"
		}
	}
}

enum LeaveRequestStatus: String {
	case waiting = "pending"
	case approved = "approved"
	case rejected = "rejected"
	case cancelled = "cancelled"
	case expired = "expired"
}
