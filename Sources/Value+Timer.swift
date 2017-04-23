//
//  Value+Timer.swift
//  Speedy
//
//  Created by Robert Sanders on 03/04/2017.
//  Copyright © 2017 Red Hand Technologies. All rights reserved.
//

/// A class that encapsulates functionality that will periodically update a value.
public class TimerFunction<T> {
    
    // MARK: - Private
    
    fileprivate let timer: Timer<T>
    
    // MARK: - Constructors
    
    internal init(timer: Timer<T>) {
        self.timer = timer
    }
    
    // MARK: - Public
    
    /// A required function that defines how a value is updated over time.
    ///
    /// - Parameter performer: The closure to be called once every time interval. The changes to T will be reflected in the associated value.
    /// - Returns: The next inspectable in the chain. In this case it is the Timer class itself.
    public func `do`(_ performer: @escaping (T) -> T) -> Inspectable<T> {
        
        timer.peformer = performer
        return timer
    }
    
}

extension Value {
    
    // MARK: - Private
    
    // MARK: - Timer Creation
    
    /// Instructs a value to begin an update loop.
    ///
    /// - Parameter timerMetadata: A meta data class used to configure the behaviour of the update loop.
    /// - Returns: A TimerFunction class that is used to define how the value is updated over time (see TimerFunction.do).
    public func tick(_ timerMetadata: TimerMetadata) -> TimerFunction<T> {
        
        let timer = Timer(timerMetadata, value: self)
        self.nextItem = timer
        return TimerFunction(timer: timer)
    }
    
    /// Instructs a value to begin an update loop configured to fire every given interval. NOTE: This creates an infinitely ticking loop.
    ///
    /// - Parameter interval: The interval between each update loop.
    /// - Returns: A TimerFunction class that is used to define how the value is updated over time (see TimerFunction.do).
    public func every(_ interval: Time) -> TimerFunction<T> {
        
        let meta = TimerMetadata(interval: interval.rawValue)
        let timer = Timer(meta, value: self)
        self.nextItem = timer
        return TimerFunction(timer: timer)
    }
}
