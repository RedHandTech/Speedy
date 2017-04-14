//
//  Wait.swift
//  Speedy
//
//  Created by Robert Sanders on 14/04/2017.
//  Copyright © 2017 Red Hand Technologies. All rights reserved.
//

import Foundation

internal var waiters: [UUID: Wait] = [:]

public class Wait {
    
    // MARK: - Private
    
    fileprivate let seconds: Float
    fileprivate var performer: (() -> ())?
    fileprivate var repeatPerformer: ((_ end: inout Bool) -> ())?
    
    fileprivate var count: Float = 0
    fileprivate var isRunning: Bool = true
    fileprivate var repeats: Bool = false
    
    fileprivate let id: UUID = UUID()
    
    /*
     * TODO: At the moment successive calls to "then" will cause multiple threads to be created.
     * INot desired behaviour as at end of wait loop the waiter is removed from the dict and will be released
     * Write further tests for multiple "then" and "repeat" calls and ensure that only 1 thread is created.
     * If user creates wait var and calls "then" multiple times what should happen?
     */
 
    //fileprivate let runningThreads: [UUID: Bool] = [:]
    
    // MARK: - Constructors
    
    
    /// Creates a new Wait instance that waits for the given number of seconds.
    ///
    /// - Parameter seconds: The number of seconds to wait for.
    init(_ seconds: Float) {
        self.seconds = seconds
        
        waiters[id] = self
    }
    
    // MARK: - Public
    
    public func then(_ perform: @escaping () -> ()) {
        self.performer = perform
        
        beginCountdown()
    }
    
    public func `repeat`(_ perform: @escaping (_ end: inout Bool) -> ()) {
        self.repeatPerformer = perform
        self.repeats = true
        
        beginCountdown()
    }
    
    public func cancel() {
        self.isRunning = false
    }
    
    // MARK: - Private
    
    fileprivate func beginCountdown() {
        
        let queue = DispatchQueue(label: "com.Speedy.SerialQueue")
        weak var welf = self
        queue.async {
            welf?.tick()
        }
    }
    
    fileprivate func tick () {
        
        defer {
            waiters[self.id] = nil
        }
        
        while isRunning {
            
            count += 1
            
            if count >= seconds {
                count = 0
                weak var welf = self
                DispatchQueue.main.async {
                    if let p = welf?.performer {
                        p()
                    } else if let p = welf?.repeatPerformer {
                        var end = false
                        p(&end)
                        guard !end else { return }
                    } else { return }
                }
                
                guard repeats else { return }
                count = 0
            }
            
            Thread.sleep(forTimeInterval: 1)
        }
    }
    
}
