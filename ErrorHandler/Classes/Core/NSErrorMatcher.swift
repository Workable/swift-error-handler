//
//  NSURLErrorMatcher.swift
//  ErrorHandler-iOS
//
//  Created by Eleni Papanikolopoulou on 02/08/2017.
//  Copyright © 2017 Workable. All rights reserved.
//

import Foundation

public struct NSErrorMatcher: ErrorMatcher {
    
    let domain: String
    var code: Int?

    public func matches(_ error: Error) -> Bool {
        let nsError = error as NSError
        
        guard nsError.domain == domain else { return false }
        
        if let code = code {
            return code == nsError.code
        }
        
        return true
    }

    public init(domain: String, code: Int?){
        self.domain =  domain
        self.code = code
    }
}
