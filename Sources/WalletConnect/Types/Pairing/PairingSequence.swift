import Foundation
import CryptoKit

struct PairingSequence: ExpirableSequence {
    let topic: String
    let relay: RelayProtocolOptions
    let selfParticipant: PairingType.Participant
    let expiryDate: Date
    private var sequenceState: Either<Pending, Settled>
    
    var publicKey: String {
        selfParticipant.publicKey
    }

    var pending: Pending? {
        get {
            sequenceState.left
        }
        set {
            if let pending = newValue {
                sequenceState = .left(pending)
            }
        }
    }
    
    var settled: Settled? {
        get {
            sequenceState.right
        }
        set {
            if let settled = newValue {
                sequenceState = .right(settled)
            }
        }
    }
    
    var isSettled: Bool {
        settled != nil
    }
    
    var peerIsController: Bool {
        isSettled && settled?.peer.publicKey == settled?.permissions.controller.publicKey
    }
    
    static var timeToLiveProposed: Int {
        Time.hour
    }
    
    static var timeToLivePending: Int {
        Time.day
    }
    
    static var timeToLiveSettled: Int {
        Time.day * 30
    }
}

extension PairingSequence {
    
    init(topic: String, relay: RelayProtocolOptions, selfParticipant: PairingType.Participant, expiryDate: Date, pendingState: Pending) {
        self.init(topic: topic, relay: relay, selfParticipant: selfParticipant, expiryDate: expiryDate, sequenceState: .left(pendingState))
    }
    
    init(topic: String, relay: RelayProtocolOptions, selfParticipant: PairingType.Participant, expiryDate: Date, settledState: Settled) {
        self.init(topic: topic, relay: relay, selfParticipant: selfParticipant, expiryDate: expiryDate, sequenceState: .right(settledState))
    }
    
    static func buildProposedFromURI(_ uri: WalletConnectURI) -> PairingSequence {
        let proposal = PairingProposal.createFromURI(uri)
        return PairingSequence(
            topic: proposal.topic,
            relay: proposal.relay,
            selfParticipant: PairingType.Participant(publicKey: proposal.proposer.publicKey),
            expiryDate: Date(timeIntervalSinceNow: TimeInterval(timeToLiveProposed)),
            pendingState: Pending(proposal: proposal, status: .proposed)
        )
    }
    
////    static func buildRespondedFromProposal(_ proposal: PairingProposal, publicKey: Curve25519.KeyAgreement.PublicKey) -> PairingSequence {
//    static func buildRespondedFromProposal(_ proposal: PairingProposal, agreementKeys: AgreementKeys) -> PairingSequence {
//        PairingSequence(
//            topic: proposal.topic,
//            relay: proposal.relay,
//            selfParticipant: PairingType.Participant(publicKey: <#T##String#>),
//            expiryDate: Date(timeIntervalSinceNow: TimeInterval(Time.day)),
//            pendingState: Pending(
//                proposal: proposal,
//                status: .responded(<#T##String#>)
//            )
//        )
//    }
}
    
extension PairingSequence {
    
    struct Pending: Codable {
        let proposal: PairingProposal
        let status: Status
        
        var isResponded: Bool {
            guard case .responded = status else { return false }
            return true
        }
        
        enum Status: Codable {
            case proposed
            case responded(String)
        }
    }

    struct Settled: Codable {
        let peer: PairingType.Participant
        let permissions: PairingType.Permissions
        var state: PairingType.State?
        var status: PairingType.Settled.SettledStatus
    }
}
