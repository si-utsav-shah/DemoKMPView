//
//  KMPSDKErrorMapping.swift
//  KMPSDKErrorMapping
//
//  Created by Utsav Shah on 25/03/26.
//

import KMPSDK

/// Maps `KMPSDK` failures into copy suitable for UI. Business meaning stays in `KMPSDK`; wording lives here.
enum KMPSDKErrorMapping {
    static func userMessage(for error: ArithmeticError) -> String {
        switch error {
        case .divisionByZero:
            return "Cannot divide by zero."
        }
    }

    static func userMessage(forUnknownServiceError error: Error) -> String {
        if error is CancellationError {
            return ""
        }
        return "Something went wrong."
    }
}
