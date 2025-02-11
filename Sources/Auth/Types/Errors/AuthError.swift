import Foundation

public enum AuthError: Codable, Equatable, Error {
    case userRejeted
    case malformedResponseParams
    case malformedRequestParams
    case messageCompromised
    case signatureVerificationFailed
}

extension AuthError: Reason {

    init?(code: Int) {
        switch code {
        case Self.userRejeted.code:
            self = .userRejeted
        case Self.malformedResponseParams.code:
            self = .malformedResponseParams
        case Self.malformedRequestParams.code:
            self = .malformedRequestParams
        case Self.messageCompromised.code:
            self = .messageCompromised
        case Self.signatureVerificationFailed.code:
            self = .signatureVerificationFailed
        default:
            return nil
        }
    }

    public var code: Int {
        switch self {
        case .userRejeted:
            return 14001
        case .malformedResponseParams:
            return 12001
        case .malformedRequestParams:
            return 12002
        case .messageCompromised:
            return 12003
        case .signatureVerificationFailed:
            return 12004
        }
    }

    public var message: String {
        switch self {
        case .userRejeted:
            return "Auth request rejected by user"
        case .malformedResponseParams:
            return "Response params malformed"
        case .malformedRequestParams:
            return "Request params malformed"
        case .messageCompromised:
            return "Original message compromised"
        case .signatureVerificationFailed:
            return "Message verification failed"
        }
    }
}
