//
//  ErrorMatcher.swift
//  workable
//
//  Created by Kostas Kremizas on 09/05/16.
//  Copyright © 2016 Workable. All rights reserved.
//

import Foundation

public protocol ErrorMatcher {
    func matches(_ error: Error) -> Bool
}

public class ErrorTypeMatcher<E: Error>: ErrorMatcher {
    public init() {}
    public func matches(_ error: Error) -> Bool {
        return error is E
    }
}

public class ClosureErrorMatcher: ErrorMatcher {
    private let matches: (Error) -> Bool
    
    public init(matches: @escaping (Error) -> Bool) {
        self.matches = matches
    }
    
    public func matches(_ error: Error) -> Bool {
        return self.matches(error)
    }
}

public func && (lhs: ErrorMatcher, rhs: ErrorMatcher) -> ErrorMatcher {
    return ClosureErrorMatcher(matches: { (error) -> Bool in
        return lhs.matches(error) && rhs.matches(error)
    })
}

public func || (lhs: ErrorMatcher, rhs: ErrorMatcher) -> ErrorMatcher {
    return ClosureErrorMatcher(matches: { (error) -> Bool in
        return lhs.matches(error) || rhs.matches(error)
    })
}

