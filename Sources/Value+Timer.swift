//
//  Value+Timer.swift
//  Speedy
//
//  Created by Robert Sanders on 03/04/2017.
//  Copyright © 2017 Red Hand Technologies. All rights reserved.
//

public class TimerFunction<T> {
    
    // MARK: - Private
    
    fileprivate let timer: Timer<T>
    
    // MARK: - Constructors
    
    internal init(timer: Timer<T>) {
        self.timer = timer
    }
    
    // MARK: - Public
    
    public func `do`(_ performer: @escaping (T) -> T) -> Inspectable<T> {
        
        // TODO: Think of better way of implementing this. Next item should never be nil but not nice to force it...
        timer.peformer = performer
        return timer
    }
    
}

extension Value {
    
    // MARK: - Private
    
    // MARK: - Timer Creation
    
    public func tick(_ timerMetadata: inout TimerMetadata) -> TimerFunction<T> {
        
        let timer = Timer(&timerMetadata, value: self)
        self.nextItem = timer
        return TimerFunction(timer: timer)
    }
    
    public func every(_ interval: Time) -> TimerFunction<T> {
        
        var meta = TimerMetadata(interval: interval.rawValue)
        let timer = Timer(&meta, value: self)
        self.nextItem = timer
        return TimerFunction(timer: timer)
    }
    

}
