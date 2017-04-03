//
//  TimerTests.swift
//  Speedy
//
//  Created by Robert Sanders on 02/04/2017.
//  Copyright © 2017 Red Hand Technologies. All rights reserved.
//

import XCTest

class TimerTests: XCTestCase {
    
    func test_tick_defaultBehaviour() {
        
        let expectation = self.expectation(description: "0 to 9")
        
        let value = Value(0)
        
        var metadata = TimerMetadata(interval: 1)
        value.tick(&metadata)
            .do { v in
                XCTAssertTrue(Thread.isMainThread)
                return v + 1
            }.inspect { if $0 == 9 {
                expectation.fulfill()
                metadata.stop()
                }
            }
        
        
        self.waitForExpectations(timeout: 14, handler: { e in
            if let e = e {
                print("Error: \(e)")
            }
        })
    }
    
    func test_every() {
        
        let expectation = self.expectation(description: "0 to 9")
        
        let value = Value(0)
        
        value.every(.second)
            .do { v in
                XCTAssertTrue(Thread.isMainThread)
                return v + 1
            }.inspect { if $0 == 9 {
                expectation.fulfill()
                }
        }
        
        
        self.waitForExpectations(timeout: 14, handler: { e in
            if let e = e {
                print("Error: \(e)")
            }
        })
    }
    
}
