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
        
        let metadata = TimerMetadata(interval: 1)
        value.tick(metadata)
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
    
    func test_timerMetadata() {
        
        let expectation = self.expectation(description: "0 to 9")
        
        let value = Value(0)
        
        let metadata = TimerMetadata(interval: 1)
        value.tick(metadata)
            .do { v in
                XCTAssertTrue(Thread.isMainThread)
                return v + 1
            }.inspect {
                XCTAssertTrue(metadata.isRunning)
                if $0 == 9 {
                    XCTAssertEqual(metadata.count, 9)
                    expectation.fulfill()
                    metadata.stop()
                    XCTAssertFalse(metadata.isRunning)
                    XCTAssertEqual(metadata.count, 0)
                }
        }
        
        self.waitForExpectations(timeout: 14, handler: { e in
            if let e = e {
                print("Error: \(e)")
            }
        })
    }
    
    func test_pause() {
        
        let expectation = self.expectation(description: "0 to 9")
        
        let value = Value(0)
        
        let metadata = TimerMetadata(interval: 1)
        value.tick(metadata)
            .do { v in
                XCTAssertTrue(Thread.isMainThread)
                return v + 1
            }.inspect {
                XCTAssertTrue(metadata.isRunning)
                if  $0 == 5 {
                    metadata.pause()
                    XCTAssertEqual(metadata.count, 5)
                    XCTAssertFalse(metadata.isRunning)
                    metadata.start()
                    XCTAssertTrue(metadata.isRunning)
                }
                if $0 == 9 {
                    XCTAssertEqual(metadata.count, 9)
                    expectation.fulfill()
                    metadata.stop()
                    XCTAssertFalse(metadata.isRunning)
                    XCTAssertEqual(metadata.count, 0)
                }
        }
        
        self.waitForExpectations(timeout: 14, handler: { e in
            if let e = e {
                print("Error: \(e)")
            }
        })
    }
    
    func test_updatesOnMainThread_false() {
        
        let expectation = self.expectation(description: "0 to 9")
        
        let value = Value(0)
        
        let metadata = TimerMetadata(interval: 1, delays: true, updatesOnMainThread: false, usesGCD: true, startImmidiately: true)
        value.tick(metadata)
            .do { v in
                XCTAssertFalse(Thread.isMainThread)
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
    
    func test_startImmidiately_false() {
        
        let expectation = self.expectation(description: "0 to 9")
        
        let value = Value(0)
        
        let metadata = TimerMetadata(interval: 1, delays: true, updatesOnMainThread: true, usesGCD: true, startImmidiately: false)
        value.tick(metadata)
            .do { v in
                return v + 1
            }.inspect { if $0 == 9 {
                XCTAssertEqual(metadata.count, 9)
                expectation.fulfill()
                metadata.stop()
                }
        }
        
        XCTAssertFalse(metadata.isRunning)
        
        Thread.sleep(forTimeInterval: 2)
        
        XCTAssertEqual(metadata.count, 0)
        
        metadata.start()
        
        XCTAssertTrue(metadata.isRunning)
        
        self.waitForExpectations(timeout: 14, handler: { e in
            if let e = e {
                print("Error: \(e)")
            }
        })
    }
    
}
