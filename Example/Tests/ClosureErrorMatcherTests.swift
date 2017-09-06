//
//  ClosureMatcherTests.swift
//  ErrorHandler-iOS Tests
//
//  Created by Kostas Kremizas on 02/08/2017.
//  Copyright © 2017 Workable. All rights reserved.
//

import XCTest
import ErrorHandler

class ClosureErrorMatcherTests: XCTestCase {
    
    func testThatClosureMatcherUsesClosureInInitialiser() {
        
        struct AnError: Error {}
        let error = AnError()
        let closure: (Error) -> Bool = { $0 is AnError }
        
        let sut = ClosureErrorMatcher(matches: closure)
        XCTAssertEqual(closure(error), sut.matches(error))
    }
    
}
