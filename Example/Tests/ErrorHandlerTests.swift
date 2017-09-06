//
//  ErrorHandlerTests.swift
//  Workable
//
//  Created by Kostas Kremizas on 25/07/2017.
//  Copyright © 2017 Workable. All rights reserved.
//

import Foundation
import XCTest
import ErrorHandler

class ErrorHandlerTests: XCTestCase {
    
    class AnError: Error {}
    
    func testThatTheActionIsCalledOnAMatch() {
        
        let error = AnError()
        
        let actionCalled = expectation(description: "Do action was called")
        
        var errorInCallBack: Error?
        ErrorHandler()
            .on(matches: { _ in true }) { (error) -> MatchingPolicy in
                actionCalled.fulfill()
                errorInCallBack = error
                return .continueMatching
        }.handle(error)
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertTrue(errorInCallBack is AnError)
    }
    
    func testThatTheActionIsNotCalledWhenThereIsNoMatch() {
        
        let error = AnError()
        let timeout = expectation(description: "Timeout for action to be called has passed")
        var actionCalled = false
        
        ErrorHandler()
            .on(matches: { _ in false }) { (error) -> MatchingPolicy in
                actionCalled = true
                return .continueMatching
            }.handle(error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            timeout.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertFalse(actionCalled)
    }
    
    func testThatOnNoMatchIsCalledWhenThereIsNoMatch() {
        
        let error = AnError()
        let actionCalled = expectation(description: "On no match action was called")
        var errorInCallBack: Error?
        
        ErrorHandler()
            .onNoMatch(do: { (error) -> MatchingPolicy in
                actionCalled.fulfill()
                errorInCallBack = error
                return .continueMatching
            }).handle(error)
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertTrue(errorInCallBack is AnError)
    }
    
    func testThatOnNoMatchIsNotCalledWhenThereIsAMatch() {
        
        let error = AnError()
        let timeout = expectation(description: "Timeout for on no match action to be called has passed")
        var actionCalled = false
        
        ErrorHandler()
            .on(matches: { _ in true }, do: { _ in .continueMatching })
            .onNoMatch(do: { (_) -> MatchingPolicy in
                actionCalled = true
                return .continueMatching
            })
            .handle(error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            timeout.fulfill()
        }
        
        waitForExpectations(timeout: 1.5)
        
        XCTAssertFalse(actionCalled)
    }
    
    func testOnNomatchWithStopMatching() {
        let error = AnError()
        let timeout = expectation(description: "Timeout for on no match action1")
        var action1Called = false
        let action2 = expectation(description: "Action 2 called")
        
        ErrorHandler()
            .onNoMatch(do: { (_) -> MatchingPolicy in
                action1Called = true
                return .continueMatching
            })
            .onNoMatch(do: { (_) -> MatchingPolicy in
                action2.fulfill()
                return .stopMatching
            })
            .handle(error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            timeout.fulfill()
        }
        
        waitForExpectations(timeout: 1.5)
        
        XCTAssertFalse(action1Called)
    }
    
    func testThatAlwaysActionIsCalledIfThereIsAMatch() {
        let error = AnError()
        let actionCalled = expectation(description: "Always was called")
        var errorInCallBack: Error?
        
        ErrorHandler()
            .on(matches: { _ in return true }, do: { _ in .stopMatching })
            .always(do: { (error) -> MatchingPolicy in
                errorInCallBack = error
                actionCalled.fulfill()
                return .continueMatching
            })
            .handle(error)
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertTrue(errorInCallBack is AnError)
    }
    
    func testThatAlwaysActionIsCalledIfThereIsNoMatch() {
        let error = AnError()
        let actionCalled = expectation(description: "Always was called")
        var errorInCallBack: Error?
        
        ErrorHandler()
            .on(matches: { _ in return false }, do: { _ in .stopMatching })
            .always(do: { (error) -> MatchingPolicy in
                errorInCallBack = error
                actionCalled.fulfill()
                return .continueMatching
            })
            .handle(error)
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertTrue(errorInCallBack is AnError)
    }
    
    func testThatActionsGetCalledInFifoOrder() {
        let error = AnError()
        let action1 = expectation(description: "Action1 was called")
        let action2 = expectation(description: "Action2 was called")

        ErrorHandler()
            .on(matches: { _ in return true }, do: { (_) -> MatchingPolicy in
                action1.fulfill()
                return .continueMatching
            })
            .on(matches: { _ in return true }, do: { (_) -> MatchingPolicy in
                action2.fulfill()
                return .continueMatching
            })
            .handle(error)
        
        wait(for: [action2, action1], timeout: 1.0, enforceOrder: true)
    }
    
    func testThatMatchingStopsIfRequested() {
        let error = AnError()
        let action2 = expectation(description: "Action1 was called")
        let action1Timeout = expectation(description: "Timeout for action2 reached")
        var action1Called = false
        
        ErrorHandler()
            .on(matches: { _ in return true }, do: { (_) -> MatchingPolicy in
                action1Called = true
                return .continueMatching
            })
            .on(matches: { _ in return true }, do: { (_) -> MatchingPolicy in
                action2.fulfill()
                return .stopMatching
            })
            .handle(error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            action1Timeout.fulfill()
        }
        
        wait(for: [action2, action1Timeout], timeout: 1.5, enforceOrder: true)
        XCTAssertFalse(action1Called, "Action after a mathing action that should stop matching was called.")
    }
    
    func testFullCase() {
        let error = AnError()
        
        let action1Timeout = expectation(description: "Timeout for action1 reached")
        var action1Called = false
        let action2 = expectation(description: "Action2 was called")
        let action3 = expectation(description: "Action3 was called")
        let action4Timeout = expectation(description: "Timeout for action1 reached")
        var action4Called = false
        let onNoMatchTimeout = expectation(description: "Timeout for on no match reached")
        var onNoMatchCalled = false
        let always1Timeout = expectation(description: "Timeout for always1 reached")
        var always1Called = false
        let always2 = expectation(description: "Always2 was called")
        let always3 = expectation(description: "Always3 was called")
        
        ErrorHandler()
            .on(matches: { _ in true }, do: { _ in
                action1Called = true
                return .continueMatching
            })
            .on(matches: { _ in return true }, do: { (_) -> MatchingPolicy in
                action2.fulfill()
                return .stopMatching
            })
            .on(matches: { _ in return true }, do: { (_) -> MatchingPolicy in
                action3.fulfill()
                return .continueMatching
            })
            .on(matches: { _ in false }, do: { _ in
                action4Called = true
                return .stopMatching
            })
            .onNoMatch(do: { (_) -> MatchingPolicy in
                onNoMatchCalled = true
                return .continueMatching
            })
            .always(do: { (_) -> MatchingPolicy in
                always1Called = true
                return .stopMatching
            })
            .always(do: { (_) -> MatchingPolicy in
                always2.fulfill()
                return .stopMatching
            })
            .always(do: { (_) -> MatchingPolicy in
                always3.fulfill()
                return .continueMatching
            })
            .handle(error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            action1Timeout.fulfill()
            action4Timeout.fulfill()
            onNoMatchTimeout.fulfill()
            always1Timeout.fulfill()
        }
        
        wait(for: [action3, action2, always3, always2], timeout: 1.5, enforceOrder: true)
        
        waitForExpectations(timeout: 1.5)
        XCTAssertFalse(action1Called, "Action after a mathing action that should stop matching was called.")
        XCTAssertFalse(action4Called, "Action that doesn't match was called.")
        XCTAssertFalse(onNoMatchCalled, "On no match action called even though there are matches.")
        XCTAssertFalse(always1Called, "Always action after a mathing always action that should stop matching was called.")
    }
    
    func testOnMatcherVariation() {
        
        struct CustomError: Error {}
        
        let error = CustomError()
        let actionCalled = expectation(description: "Action called")
        var errorInCallback: Error?
        
        ErrorHandler()
            .on(ErrorTypeMatcher<CustomError>()) { (error) -> MatchingPolicy in
                actionCalled.fulfill()
                errorInCallback = error
                return .continueMatching
        }.handle(error)
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertTrue(errorInCallback is CustomError)
    }
    
    func testOnErrorOfType() {
        
        let error = AnError()
        let actionCalled = expectation(description: "Action called")
        var errorInCallback: Error?
        
        ErrorHandler()
            .onError(ofType: AnError.self, do: { (error) -> MatchingPolicy in
                actionCalled.fulfill()
                errorInCallback = error
                return .continueMatching
            })
            .handle(error)
        
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(errorInCallback is AnError)
    }
    
    func testTaggingMatcher() {
        let error = AnError()
        let actionCalled = expectation(description: "Action called")
        var errorInCallback: Error?
        
        ErrorHandler()
            .tag(ErrorTypeMatcher<AnError>(), with: "AnError")
            .on(tag: "AnError") { (error) -> MatchingPolicy in
                actionCalled.fulfill()
                errorInCallback = error
                return .continueMatching
            }.handle(error)
        
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(errorInCallback is AnError)
    }
    
    func testTaggingWhenTheTagAlreadyExists() {
        
        struct InvalidStateError: Error {}
        struct BadDataError: Error {}
        
        let error = InvalidStateError()
        let actionCalled = expectation(description: "Action called")
        
        ErrorHandler()
            .tag(ErrorTypeMatcher<BadDataError>(), with: "CustomError")
            .tag(ErrorTypeMatcher<InvalidStateError>(), with: "CustomError")
            .on(tag: "CustomError") { (_) -> MatchingPolicy in
                actionCalled.fulfill()
                return .continueMatching
            }.handle(error)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testTaggingMatchesFunction() {
        let error = AnError()
        let actionCalled = expectation(description: "Action called")
        var errorInCallback: Error?
        
        ErrorHandler()
            .tag(matches: { $0 is AnError }, with: "AnError")
            .on(tag: "AnError") { (error) -> MatchingPolicy in
                actionCalled.fulfill()
                errorInCallback = error
                return .continueMatching
            }.handle(error)
        
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(errorInCallback is AnError)
    }
    
    func testOnTagWithNoExistingMatcherDoesNothing() {
        let error = AnError()
        let actionTimeout = expectation(description: "Action called")
        var actionCalled = false
        
        ErrorHandler()
            .tag(matches: { $0 is AnError }, with: "AnError")
            .on(tag: "CustomError") { (_) -> MatchingPolicy in
                actionCalled = true
                return .continueMatching
            }.handle(error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            actionTimeout.fulfill()
        }
        waitForExpectations(timeout: 1.2)
        XCTAssertFalse(actionCalled)
    }
    
    func testOnEquatableError() {
        
        enum ValidationError: Error {
            case invalidEmail
            case invalidPassword
        }
        
        let invalidEmailActionCalled = expectation(description: "Invalid email action called")
        let invalidPasswordTimeoutReached = expectation(description: "Invalid password cation not called")
        var invalidPasswordActionCalled = false
        
        ErrorHandler()
            .on(ValidationError.invalidEmail, do: { (_) -> MatchingPolicy in
                invalidEmailActionCalled.fulfill()
                return .continueMatching
            })
            .on(ValidationError.invalidPassword, do: { (_) -> MatchingPolicy in
                invalidPasswordActionCalled = true
                return .continueMatching
            })
            .handle(ValidationError.invalidEmail)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            invalidPasswordTimeoutReached.fulfill()
        }
        waitForExpectations(timeout: 1.2)

        XCTAssertFalse(invalidPasswordActionCalled)
    }
}
