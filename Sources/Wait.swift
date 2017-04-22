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
    fileprivate var isRunning: Bool = false
    fileprivate var repeats: Bool = false
    
    fileprivate let id: UUID = UUID()
    
    // MARK: - Constructors
    
    /// Creates a new Wait instance that waits for the given number of seconds.
    ///
    /// - Parameter seconds: The number of seconds to wait for.
    init(_ seconds: Float) {
        self.seconds = seconds
        
        waiters[id] = self
    }
    
    // MARK: - Public
    
    /// Specifies the closure to be called after the wait is over.
    ///
    /// - Parameter perform: The closure to be performed.
    public func then(_ perform: @escaping () -> ()) {
        
        guard !isRunning else {
            #if DEBUG
                print("Err: Wait block already running.")
            #endif
            return
        }
        
        self.performer = perform
        beginCountdown()
    }
    
    /// Specifies the closure to be called every n seconds.
    ///
    /// - Parameter perform: The closure to be performed.
    public func `repeat`(_ perform: @escaping (_ end: inout Bool) -> ()) {
        
        guard !isRunning else {
            #if DEBUG
                print("Err: Wait block already running.")
            #endif
            return
        }
        
        self.repeatPerformer = perform
        self.repeats = true
        beginCountdown()
    }
    
    public func cancel() {
        isRunning = false
        waiters[id] = nil
    }
    
    // MARK: - Private
    
    fileprivate func beginCountdown() {
        
        isRunning = true
        
        let queue = DispatchQueue(label: "com.Speedy.SerialQueue")
        weak var welf = self
        queue.async {
            welf?.tick()
        }
    }
    
    fileprivate func tick () {
        
        while isRunning {
            
            count += 1
            
            if count >= seconds {
                weak var welf = self
                DispatchQueue.main.async {
                    
                    // assert welf
                    guard let s = welf else { return }
                    
                    if let p = s.performer {
                        p()
                        // one time wait so exit
                        s.cancel()
                        return
                    }
                    
                    if let p = s.repeatPerformer {
                        var end = false
                        p(&end)
                        guard !end else { s.cancel(); return }
                    }
                }
                
                if repeats {
                    count = 0
                }
            }
            
            Thread.sleep(forTimeInterval: 1)
        }
    }
    
}
