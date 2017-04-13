//
//  SpeedyTests.swift
//  Speedy
//
//  Created by Robert Sanders on 18/02/2017.
//  Copyright © 2017 Red Hand Technologies. All rights reserved.
//

import XCTest

class SpeedyTests: XCTestCase {
    
    func test_value() {
        
        let val = Value(10)
        XCTAssertEqual(val.value, 10)
        
        val.value = 20
        XCTAssertEqual(val.value, 20)
    }
    
    func test_monitor() {
        
        let val = Value(10)
        
        var didCall = false
        
        val.inspect { XCTAssertEqual($0, 2); didCall = true }
        
        val.value = 2
        XCTAssertTrue(didCall)
    }
    
    func test_transform() {
        
        let val = Value(10)
        
        var didCall = false
        
        val.map { String($0) }
            .inspect { XCTAssertEqual($0, "2"); didCall = true }
        
        val.value = 2
        XCTAssertTrue(didCall)
    }
    
    func test_evaluate() {
        
        let val = Value(10)
        
        var didCall = false
        
        val.when { $0 != 1 }
            .inspect { _ in didCall = true }
        
        val.value = 1
        XCTAssertFalse(didCall)
        val.value = 2
        XCTAssertTrue(didCall)
    }
    
    func test_sequence() {
        
        let val = Value(10)
        
        var didCall = false
        
        val.when { $0 != 1 }
            .map { String($0) }
            .when { $0 != "2" }
            .inspect { _ in didCall = true }
        
        val.value = 1
        XCTAssertFalse(didCall)
        val.value = 2
        XCTAssertFalse(didCall)
        val.value = 3
        XCTAssertTrue(didCall)
    }
    
    func test_multipleWatch() {
        
        let val = Value(10)
        
        var didCallOne = false
        var didCallTwo = false
        
        val.when { $0 != 1 }
            .map { String($0) }
            .watch { _ in didCallOne = true }
            .when { $0 != "2" }
            .inspect { _ in didCallTwo = true }
        
        val.value = 1
        XCTAssertFalse(didCallOne)
        XCTAssertFalse(didCallTwo)
        val.value = 2
        XCTAssertTrue(didCallOne)
        XCTAssertFalse(didCallTwo)
        val.value = 3
        XCTAssertTrue(didCallOne)
        XCTAssertTrue(didCallTwo)
    }
    
    func test_oldValue() {
        
        let val = Value(10)
        
        XCTAssertNil(val.oldValue)
        
        val.value = 1
        
        XCTAssertEqual(val.oldValue, 10)
    }
    
    func test_compare() {
        
        let val = Value("Hello")
        
        var didCall = false
        
        val.compare { $0 != $1 }
            .inspect { _ in didCall = true }
        
        val.value = "Hello"
        
        XCTAssertFalse(didCall)
        
        val.value = "Hello, World!"
        
        XCTAssertTrue(didCall)
    }
    
    func test_distinct() {
        
        let val = Value("Hello")
        
        var didCall = false
        
        val.distinct()
            .inspect { _ in didCall = true }
        
        val.value = "Hello"
        
        XCTAssertFalse(didCall)
        
        val.value = "Hello, World!"
        
        XCTAssertTrue(didCall)
    }
    
}




