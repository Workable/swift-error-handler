//
//  ErrorHandlerClass.swift
//  workable
//
//  Created by Kostas Kremizas on 09/05/16.
//  Copyright © 2016 Workable. All rights reserved.
//

import Foundation

public enum MatchingPolicy {
    case continueMatching
    case stopMatching
}

public typealias ErrorAction = (Error) -> MatchingPolicy

public typealias Tag = String

/**
 An ErrorHandler is responsible for handling an error by executing one or more actions, that are found to match the error.
 
 You can add the rules for matching and the actions that will be executed when a match occurs by using the `on(_:do)` method variants.
 
 You can add actions to be executed when there is no match with the onNoMatch(do:) method and actions that will be executed regardless of whether there is a match or not with `always(do:).`
 */
open class ErrorHandler {
    fileprivate var errorActions: [(ErrorMatcher, ErrorAction)] = []
    fileprivate var onNoMatch: [ErrorAction] = []
    fileprivate var alwaysActions: [ErrorAction] = []
    
    fileprivate var tagsDictionary = [Tag: [ErrorMatcher]]()
    
    public init() {
    }
    
    /**
     Defines an action to be executed if the error handled by the error handler metches the `matches` function.
     - Parameters:
         - matches: If this closure returns true, the `action` parameter will be executed.
         - action: The closure that will be executed if `matches` returns true. The action returns a `MatchingPolicy` instance. If the action is called and returns `MatchingPolicy.continueMatching`, the error handle continues to execute the actions corresponding to other potential matches for the handled error. If the action is called and returns `MatchingPolicy.stopMatching` no other matching action is executed, except actions defined with the `always(do:)` method.
     - Returns: The updated error handler (self).
     - Note: When the `handle` method is called the matching functions are called in lifo order. First is checked the `matches` function given by the last `on(matches:do:)` call. The reasoning behind this is that the last `on(matches:do:)` call is the last customization made to the handler by the developer and as such, it's action should have priority if there are multiple matches.
     */
    public func on(matches: @escaping ((Error) -> Bool), do action: @escaping ErrorAction) -> ErrorHandler {
        let matcher = ClosureErrorMatcher(matches: matches)
        return on(matcher, do: action)
    }
    
    /**
     Defines an action to be executed if the `matcher` matches the error handled by the error handler.
     - Parameters:
         - matcher: The matcher that defines if the `action` closure will be called (if it's `matches` function returns true).
         - action: The closure that will be executed if the `matcher` matches the error. The action returns a `MatchingPolicy` instance. If the action is called and returns `MatchingPolicy.continueMatching`, the error handle continues to execute the actions corresponding to other potential matches for the handled error. If the action is called and returns `MatchingPolicy.stopMatching` no other matching action is executed, except actions defined with the `always(do:)` method.
     - Returns: The updated error handler (self).
     - Note: When the `handle` method is called the matching functions are called in lifo order. First is checked the `matches` function given by the last `on(_:do:)` call. The reasoning behind this is that the last `on(matches:do:)` call is the last customization made to the handler by the developer and as such, it's action should have priority if there are multiple matches.
     */
    public func on(_ matcher: ErrorMatcher, do action: @escaping ErrorAction) -> ErrorHandler {
        errorActions.append((matcher, action))
        return self
    }
    
    /**
     Adds an action to be executed if there is no match for the error being handled.
     - Parameters:
         - action: The closure that will be executed if there is no match. The action returns a `MatchingPolicy` instance. If the action is called and returns `MatchingPolicy.continueMatching`, the error handle continues to execute the previously added `onNoMatch` actions. If the action is called and returns `MatchingPolicy.stopMatching` no other `onNoMatch` action is executed. This way you can override previously defined `onNoMatch` actions.
     - Returns: The updated error handler (self).
     - Note: You can add multiple `onNoMatch` actions and they will be executed in lifo order until one of them returns MatchingPolicy.stopMatching. The reasoning behind this is that the last `onNoMatch` call is the last customization made to the handler's `onNoMatch` actions and as such, it should have priority.
     */
    public func onNoMatch(do action: @escaping ErrorAction) -> ErrorHandler {
        onNoMatch.append(action)
        return self
    }
    
    /**
     Adds an action to be executed whether there is a match for the error or not. This action will be called after potential matching actions have been called.
     - Parameters:
         - action: The closure that will be executed if there is no match. The action returns a `MatchingPolicy` instance. If the action is called and returns `MatchingPolicy.continueMatching`, the error handle continues to execute the previously added `always` actions. If the action is called and returns `MatchingPolicy.stopMatching` no other `always` action is executed. This way you can override previously defined `always` actions.
         - Returns: The updated error handler (self).
     - Note: You can add multiple `always` actions and they will be executed in lifo order until one of them returns `MatchingPolicy.stopMatching`.
     */
    public func always(do action: @escaping ErrorAction) -> ErrorHandler {
        alwaysActions.append(action)
        return self
    }
    
    /**
     Looks for actions that match the error (added with `on(matches:do:)`) and executes them. If there are no matching actions, `onNoMatch` actions will be executed. In any case, `always` actions will also be executed.
     - Parameter error: The error to handle.
     */
    public func handle(_ error: Error) {
        
        defer {
            for alwaysAction in alwaysActions.reversed() {
                let alwaysMatchingPolicy = alwaysAction(error)
                if case .stopMatching = alwaysMatchingPolicy {
                    break
                }
            }
        }
        
        var foundMatch = false
        for (matcher, action) in errorActions.reversed() {
            if matcher.matches(error) {
                foundMatch = true
                let policy = action(error)
                if case .stopMatching = policy {
                    return
                }
            }
        }
        
        if foundMatch { return }
        
        for otherwise in onNoMatch.reversed() {
            let policy = otherwise(error)
            if case .stopMatching = policy {
                break
            }
        }
    }
    
    /**
     Adds a tag (of type `String`) to a specific `matches` closure. After this you can use `on(tag:do:)` to link actions to all the `matches` closures that have been assigned this tag. This way you can group many `matches` closures together, refer to them by a memorizeable tag and handle the errors that match any of them by calling the same action.
     
     For example you can tag with "NetworkError" all the `matches` closures that match an error related to the network and handle such errors the same way.
     
     ````
     ErrorHandler()
     .tag(matches: {...}, with: "NetworkError")
     .tag(matches: {...}, with: "NetworkError")
     .on(tag: "NetworkError", do: {...})
     ````
     An alternative would be to create a new `matcher` or matches function that matches if all the other `matchers` match and use this.

     - Parameters:
         - matches: the closure that will be given a tag.
         - tag: A `String` with which the `matches` closure (and any other tagged the same way) can referred with in the `on(tag:do:)` method.
     - Returns: The updated error handler (self).
     */
    public func tag(matches: @escaping ((Error) -> Bool), with tag: Tag) -> ErrorHandler {
        let matcher = ClosureErrorMatcher(matches: matches)
        return self.tag(matcher, with: tag)
    }
    
    /**
     Adds a tag (of type `String`) to a specific `matcher`. After this you can use `on(tag:do:)` to link actions to all the `matchers` that have been assigned this tag. This way you can group many `matchers` closures together, refer to them by a memorizeable tag and handle the errors that match any of them by calling the same action.
     
     For example you can tag with "NetworkError" all the `matchers` that match an error related to the network and handle such errors the same way.
     
     ````
     ErrorHandler()
     .tag(connectionFailedMatcher, with: "NetworkError")
     .tag(timeoutErrorMatcher, with: "NetworkError")
     .on(tag: "NetworkError", do: {...})
     ````
     An alternative would be to create a new `matcher` or matches function that matches if all the other `matchers` match and use this.

     - Parameters:
         - matcher: The closure that will be given a tag.
         - tag: A `String` with which the `matches` closure (and any other tagged the same way) can referred with in the `on(tag:do:)` method.
     - Returns: The updated error handler (self).
     */
    public func tag(_ matcher: ErrorMatcher, with tag: Tag) -> ErrorHandler {
        if tagsDictionary[tag] != nil {
            tagsDictionary[tag]?.append(matcher)
        } else {
            tagsDictionary[tag] = [matcher]
        }
        return self
    }
    
    /**
     Adds an action to all the `matches` closures that have been assigned this tag. This way you can group many `matches` closures together, refer to them by a memorizeable tag and handle the errors that match any of them by calling the same action.
     - Returns: The updated error handler (self).
     */
    public func on(tag: Tag, do action: @escaping ErrorAction) -> ErrorHandler {
        guard let taggedMatchers = tagsDictionary[tag] else { return self }
        let matherActionsPairs = taggedMatchers.map({ ($0, action) })
        errorActions.append(contentsOf: matherActionsPairs)
        return self
    }
    
    /**
     Defines an action to be executed if the error is any error of the given type `T`. In essence it is just a convenience method for calling `on(_:do:)` with a matcher that checks the type of the error.
     
     - Parameters:
         - type: The type the error must be in order for the `action` to be called.
         - action: The closure that will be executed if the error is of type `T`.
     - Returns: The updated error handler (self).
     */
    public func onError<T: Error>(ofType type: T.Type, do action: @escaping ErrorAction) -> ErrorHandler {
        return on(ErrorTypeMatcher<T>(), do: action)
    }
    
    /**
     Defines an action to be executed if the error handled by the error handler is equal to the given `Equatable` error.
     
     - Parameters:
     - error: An `Equatable` `Error` we want to handle with the `action` closure.
     - action: The closure that will be called if the error being handled is equal to the given error (1st parameter).
     - Returns: The updated error handler (self).
     */
    public func on<E: Error & Equatable>(_ error: E, do action: @escaping ErrorAction) -> ErrorHandler {
        return self.on(
            matches: { (handledError) -> Bool in
                guard let handledError = handledError as? E else { return false }
                return handledError == error
        }, do: action)
    }
    
    public func onNSError(domain: String, code: Int? = nil, do action: @escaping ErrorAction) -> ErrorHandler {
        return self.on(NSErrorMatcher(domain: domain, code: code), do: action)
    }
}

public func tryWith(_ handler: ErrorHandler, closure: () throws -> Void) {
    do {
        try closure()
    } catch {
        handler.handle(error)
    }
}


