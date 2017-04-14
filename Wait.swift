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
    
    fileprivate var count: Float = 0
    fileprivate var isRunning: Bool = true
    
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
    
    public func then(_ perform: @escaping () -> ()) {
        self.performer = perform
        
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
                    welf?.performer?()
                }
                
                return
            }
            
            Thread.sleep(forTimeInterval: 1)
        }
    }
    
}
