//
//  Wait.swift
//  Speedy
//
//  Created by Robert Sanders on 14/04/2017.
//  Copyright © 2017 Red Hand Technologies. All rights reserved.
//

import Foundation

public class Wait {
    
    // MARK: - Private
    
    fileprivate let seconds: Float
    fileprivate var performer: (() -> ())?
    
    fileprivate var count: Float = 0
    fileprivate var isRunning: Bool = true
    
    // MARK: - Constructors
    
    init(_ seconds: Float) {
        self.seconds = seconds
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
        
        while isRunning {
            count += 1
            
            if count >= seconds {
                isRunning = false
                count = 0
                weak var welf = self
                DispatchQueue.main.async {
                    welf?.performer?()
                }
            }
            
            Thread.sleep(forTimeInterval: 1)
        }
    }
    
}
