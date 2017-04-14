//
//  WaitTests.swift
//  Speedy
//
//  Created by Robert Sanders on 14/04/2017.
//  Copyright © 2017 Red Hand Technologies. All rights reserved.
//

import XCTest

class WaitTests: XCTestCase {
    
    func test_wait() {
        
        let expectation = self.expectation(description: "Wait for 3")
        
        Wait(3).then {
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 4, handler: { err in
            if let e = err {
                print("Error: \(e)")
            }
        })
    }
    
    func test_repeat_wait() {
        
        let expectation = self.expectation(description: "Wait for 1 3 times")
        
        var count = 0
        Wait(1).repeat {
            count += 1
            if count >= 3 {
                $0 = true
                expectation.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: 4, handler: { err in
            if let e = err {
                print("Error: \(e)")
            }
        })
    }
    
}
