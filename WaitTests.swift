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
    
}
