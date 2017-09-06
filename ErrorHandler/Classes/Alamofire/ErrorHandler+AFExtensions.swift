//
//  ErrorHandler+AFExtensions.swift
//  ErrorHandler+AFExtensions
//
//  Created by Kostas Kremizas on 30/08/2017.
//  Copyright © 2017 Workable SA. All rights reserved.
//

import Foundation
#if !COCOAPODS
    import ErrorHandler
#endif

public extension ErrorHandler {
    
    public func onAFError(withStatus statusCode: Int, do action: @escaping ErrorAction) -> ErrorHandler {
        let matcher = AFErrorStatusCodeMatcher(statusCode: statusCode)
        return self.on(matcher, do: action)
    }
    
    public func onAFError(withStatus range: Range<Int>, do action: @escaping ErrorAction) -> ErrorHandler {
        let matcher = AFErrorStatusCodeMatcher(range)
        return self.on(matcher, do: action)
    }
}
