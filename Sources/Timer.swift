//
//  Timer.swift
//  Speedy
//
//  Created by Robert Sanders on 01/04/2017.
//  Copyright © 2017 Red Hand Technologies. All rights reserved.
//

import Foundation

internal class Timer<T>: Inspectable<T> {
    
    // MARK: - Private
    
    fileprivate let interval: Float
    
    // MARK: - Constructors
    
    internal init(interval: Float) {
        self.interval = interval
    }
    
    // MARK: - Private
    
    // Use this: http://stackoverflow.com/questions/25944190/making-timer-swift-without-nstimer
    
    // MARK: - Override
    
    internal override func perform(_ value: Any, oldValue: Any?) {
        
        nextItem?.perform(value, oldValue: oldValue)
    }
    
}
