//
//  ErrorHandler-AFExtensionsTests.swift
//  Workable SA
//
//  Created by Kostas Kremizas on 01/09/2017.
//  Copyright © 2017 Workable SA. All rights reserved.
//

import Foundation
import XCTest
import Alamofire
import ErrorHandler

class ErrorHandlerAFExtensionsTests: XCTestCase {
    
    func testThatItMatchesErrorWithSameStatus() {
        let code = 404
        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: code))
        let actionCalled = expectation(description: "Do action was called")

        
        ErrorHandler()
            .onAFError(withStatus: 404) { (_) -> MatchingPolicy in
                actionCalled.fulfill()
                return .continueMatching
            }
            .handle(error)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testThatItDoesntMatchErrorWithOtherStatus() {
        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 400))
        let timeout = expectation(description: "Timeout for action to be called has passed")
        var actionCalled = false
        
        ErrorHandler()
            .onAFError(withStatus: 404) { (error) -> MatchingPolicy in
                actionCalled = true
                return .continueMatching
            }.handle(error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            timeout.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertFalse(actionCalled)
    }
    
    func testThatItMatchesErrorInCorrectRange() {
        let code = 404
        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: code))
        let actionCalled = expectation(description: "Do action was called")
        
        
        ErrorHandler()
            .onAFError(withStatus: 400..<500) { (_) -> MatchingPolicy in
                actionCalled.fulfill()
                return .continueMatching
            }
            .handle(error)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testThatItDoesNotMatchErrorOutsideRange() {
        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 500))
        let timeout = expectation(description: "Timeout for action to be called has passed")
        var actionCalled = false
        
        ErrorHandler()
            .onAFError(withStatus: 400..<430) { (error) -> MatchingPolicy in
                actionCalled = true
                return .continueMatching
            }.handle(error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            timeout.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertFalse(actionCalled)
    }
    
    func testThatItDoesNotMatchAFErrorOfDifferentReason() {
        let error = AFError.responseValidationFailed(reason: .dataFileNil)
        let timeout = expectation(description: "Timeout for action to be called has passed")
        var actionCalled = false
        
        ErrorHandler()
            .onAFError(withStatus: 400..<430) { (error) -> MatchingPolicy in
                actionCalled = true
                return .continueMatching
            }.handle(error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            timeout.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertFalse(actionCalled)
    }
    
    func testThatItDoesntMatchOtherTypesOfAFErrorReasons() {
        let error = AFError.parameterEncodingFailed(reason: .missingURL)
        
        let timeout = expectation(description: "Timeout for action to be called has passed")
        var actionCalled = false
        
        ErrorHandler()
            .onAFError(withStatus: 400..<430) { (error) -> MatchingPolicy in
                actionCalled = true
                return .continueMatching
            }.handle(error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            timeout.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertFalse(actionCalled)
    }
    
    func testThatItDoesntMatchOtherTypesOfErrors() {
        let error = NSError(domain: "foo", code: 9, userInfo: nil)

        
        let timeout = expectation(description: "Timeout for action to be called has passed")
        var actionCalled = false
        
        ErrorHandler()
            .onAFError(withStatus: 400..<430) { (error) -> MatchingPolicy in
                actionCalled = true
                return .continueMatching
            }.handle(error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            timeout.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertFalse(actionCalled)
    }
}
