//
//  NSErrorMatcherTests.swift
//  ErrorHandler-iOS
//
//  Created by Eleni Papanikolopoulou on 05/08/2017.
//  Copyright © 2017 Workable. All rights reserved.
//

import XCTest
import ErrorHandler

class NSErrorMatcherTests: XCTestCase {

    func testThatItMatchesNsErrorsWithSameDomainAndCode() {

        // Arrange
        let domain = "test_domain"
        let nsError = NSError(domain: domain, code: 1, userInfo: nil)
        let sut = NSErrorMatcher(domain: domain, code: 1)

        // Act - Assert
        XCTAssertTrue(sut.matches(nsError))
    }

    func testThatItDoesNotMatchErrorsOfDifferentType() {
        // Arrange
        let nsError = NSError(domain: "test_domain", code: 1, userInfo: nil)
        let sut = NSErrorMatcher(domain: "different_domain", code: 1)

        // Act - Assert
        XCTAssertFalse(sut.matches(nsError))
    }
    
    func testThatItMatchesNsErrorsWithSameDomainIfCodeIsNill() {
        // Arrange
        let domain = "test_domain"
        let nsError = NSError(domain: domain, code: 3, userInfo: nil)
        let sut = NSErrorMatcher(domain: domain, code: nil)
        
        //Act - Assert
        XCTAssertTrue(sut.matches(nsError))
    }
}
