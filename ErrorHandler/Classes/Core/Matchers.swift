//
//  ErrorMatcher.swift
//  workable
//
//  Created by Kostas Kremizas on 09/05/16.
//  Copyright © 2016 Workable. All rights reserved.
//

import Foundation

/**
 An `ErrorMatcher` is an alternative to using `matches` closures when adding `ErrorActions` to an `ErrorHandler`. An `ErrorMatcher` is considered to match an error when it's `matches` function returns `true` for this error. `ErrorMatcher`s are used to match errors with the `ErrorHandler`'s `on(_ matcher: ErrorMatcher, do action: @escaping ErrorAction)` method.

 `ErrorMatcher`s can be combined using || and && operators.
 For example:

 ```
 let notConnectedMatcher = NSErrorMatcher(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)

 let connectionLostMatcher = NSErrorMatcher(domain:   NSURLErrorDomain, code: NSURLErrorNetworkConnectionLost)

 let offlineMatcher = notConnectedMatcher || connectionLostMatcher
 ```
 Error matchers have the additional benefit compared to `matches` closures that they describe matching logic in a way that can be more naturally reused. i.e. it is more natural in `Swift` to reuse Types than free functions and closures as the unit of composition in Swift is the type.
 */
public protocol ErrorMatcher {

    /**
     The `ErrorMatcher` is considered to match the error if this function returns true.
     - Returns: `true` if the matcher matches the `error` otherwise `false`
     */
    func matches(_ error: Error) -> Bool
}

/**
 A generic `ErrorMatcher` over type `E` that `matches` an error if the error `is` `T`
 */
public class ErrorTypeMatcher<E: Error>: ErrorMatcher {
    public init() {}
    public func matches(_ error: Error) -> Bool {
        return error is E
    }
}

/**
 An `ErrorMatcher` that wraps a `matches` closure
 */
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

