//
//  ErrorHandler-AFExtensions.swift
//  Workable SA
//
//  Created by Kostas Kremizas on {TODAY}.
//  Copyright © 2017 Workable SA. All rights reserved.
//

import Foundation
import Alamofire
#if !COCOAPODS
    import ErrorHandler
#endif

public class AFErrorStatusCodeMatcher: ErrorMatcher {
    
    private let validRange: Range<Int>
    
    public init(_ range: Range<Int>) {
        self.validRange = range
    }
    
    public init(statusCode: Int) {
        self.validRange = statusCode..<statusCode + 1
    }
    
    public func matches(_ error: Error) -> Bool {
        guard let error = error as? AFError else { return false }
        guard case .responseValidationFailed(reason: let validationFailureReason) = error else { return false }
        guard case .unacceptableStatusCode(code: let statusCode) = validationFailureReason else { return false }
        return validRange ~= statusCode
    }
}
