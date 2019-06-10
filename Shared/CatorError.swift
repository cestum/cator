//
//  CatorError.swift
//  Cator
//
//  Created by Cestum on 6/10/19.
//

import Foundation

enum CatorError: Error {
    case unexpectedError
    case notImplementedYetError
    case serverError(code: Int)
    case responseError(code: Int, message: String?)
}

extension CatorError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .unexpectedError:
                return NSLocalizedString("UNEXPECTEDERROR", comment: "")
            case .notImplementedYetError:
                return NSLocalizedString("NOTIMPLEMENTEDERROR", comment: "Functionality not implemented yet. Sorry!")
            case .serverError(let code):
                let statusMessage = HTTPURLResponse.localizedString(forStatusCode: code)
                return "\(code): \(statusMessage)"
            case .responseError(let code, let message):
                if let serverMessage = message {
                    return NSLocalizedString(serverMessage, comment: "Server Error Code")
                } else {
                    return "\(code): \(HTTPURLResponse.localizedString(forStatusCode: code))"
                }
            }
    }
}
