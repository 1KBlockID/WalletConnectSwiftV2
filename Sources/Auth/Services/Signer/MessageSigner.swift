import Foundation

protocol MessageSignatureVerifying {
    func verify(signature: String, message: String, address: String) throws
}

protocol MessageSigning {
    func sign(message: String, privateKey: Data) throws -> String
}

public struct MessageSigner: MessageSignatureVerifying, MessageSigning {

    enum Errors: Error {
        case signatureValidationFailed
        case utf8EncodingFailed
    }

    private let signer: Signer

    public init(signer: Signer = Signer()) {
        self.signer = signer
    }

    public func sign(message: String, privateKey: Data) throws -> String {
        guard let messageData = message.data(using: .utf8) else { throw Errors.utf8EncodingFailed }
        let signature = try signer.sign(message: messageData, with: privateKey)
        return signature.toHexString()
    }

    public func verify(signature: String, message: String, address: String) throws {
        guard let messageData = message.data(using: .utf8) else { throw Errors.utf8EncodingFailed }
        let signatureData = Data(hex: signature)
        guard try signer.isValid(signature: signatureData, message: messageData, address: address)
        else { throw Errors.signatureValidationFailed }
    }
}
