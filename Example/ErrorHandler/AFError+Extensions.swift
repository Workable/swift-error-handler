//
//  AFError+Extensions.swift
//  ErrorHandler_Example
//
//  Created by Kostas Kremizas on 01/09/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Alamofire

extension AFError {
    init(statusCode: Int) {
        self = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: statusCode))
    }
}
