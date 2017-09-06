//
//  ErrorTypeMatcherTests.swift
//  ErrorHandler-iOS Tests
//
//  Created by Kostas Kremizas on 25/07/2017.
//  Copyright © 2017 Workable. All rights reserved.
//

import XCTest
import ErrorHandler

class ErrorTypeMatcherTests: XCTestCase {
    
    func testThatErrorTypeMatcherMatchesErrorOfSameType() {
        
        // Arrange
        struct CustomError: Error {}
        let sut = ErrorTypeMatcher<CustomError>()
        let error: Error = CustomError()
        
        // Act - Assert
        XCTAssertTrue(sut.matches(error))
    }
    
    func testThatErrorTypeMatcherDoesNotMatchErrorOfDifferentType() {
        
        // Arrange
        struct CustomError: Error {}
        let sut = ErrorTypeMatcher<CustomError>()
        
        struct AnotherCustomError: Error {}
        let error: Error = AnotherCustomError()
        
        // Act - Assert
        XCTAssertFalse(sut.matches(error))
    }
}
