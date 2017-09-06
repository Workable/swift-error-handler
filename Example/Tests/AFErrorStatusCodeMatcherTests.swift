//
//  AFErrorStatusCodeMatcherTests.swift
//  ErrorHandler-AFExtensions
//
//  Created by Kostas Kremizas on 30/08/2017.
//  Copyright © 2017 Workable SA. All rights reserved.
//

import Foundation
import XCTest
import Alamofire
import ErrorHandler

class AFErrorStatusCodeMatcherTests: XCTestCase {
    
    func testThatItMatchesErrorWithSameStatus() {
        let code = 404
        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: code))
        
        let matcher = AFErrorStatusCodeMatcher(statusCode: code)
        
        XCTAssertTrue(matcher.matches(error))
    }
    
    func testThatItDoesntMatchErrorWithOtherStatus() {
        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 404))
        
        let matcher = AFErrorStatusCodeMatcher(statusCode: 400)
        
        XCTAssertFalse(matcher.matches(error))
    }
    
    func testThatItMatchesErrorInCorrectRange() {
        let matcher = AFErrorStatusCodeMatcher(400..<430)
        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 412))
        XCTAssertTrue(matcher.matches(error))
    }
    
    func testThatItDoesNotMatchErrorOutsideRange() {
        let matcher = AFErrorStatusCodeMatcher(400..<430)
        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 500))
        XCTAssertFalse(matcher.matches(error))
    }
    
    func testThatItDoesNotMatchAFErrorOfDifferentReason() {
        let error = AFError.responseValidationFailed(reason: .dataFileNil)
        let matcher = AFErrorStatusCodeMatcher(400..<500)
        XCTAssertFalse(matcher.matches(error))
    }
    
    func testThatItDoesntMatchOtherTypesOfAFErrorReasons() {
        let error = AFError.parameterEncodingFailed(reason: .missingURL)
        let matcher = AFErrorStatusCodeMatcher(400..<500)
        XCTAssertFalse(matcher.matches(error))
    }
    
    func testThatItDoesntMatchOtherTypesOfErrors() {
        let error = NSError(domain: "foo", code: 9, userInfo: nil)
        let matcher = AFErrorStatusCodeMatcher(400..<500)
        XCTAssertFalse(matcher.matches(error))
    }
}
