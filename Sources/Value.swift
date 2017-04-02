//
//  Value.swift
//  Speedy
//
//  Created by Robert Sanders on 18/02/2017.
//  Copyright © 2017 Red Hand Technologies. All rights reserved.
//

public class Value<T>: Inspectable<T> {
    
    // MARK: - Public
    
    public var value: T {
        get {
            return _value
        } set {
            oldValue = value
            _value = newValue
        }
    }
    
    private(set) public var oldValue: T?
    
    // MARK: - Private
    
    fileprivate var _value: T {
        didSet {
            perform(_value, oldValue: oldValue)
        }
    }
    
    // MARK: - Constructors
    
    public init(_ value: T) {
        _value = value
    }
    
    // MARK: - Public
    
    public func onTick(_ timerMetadata: inout TimerMetadata) -> Inspectable<T> {
        
        let timer = Timer(&timerMetadata, value: self)
        nextItem = timer
        return timer.token
    }
    
    public func evey(_ interval: Time) -> Inspectable<T> {
        
        var meta = TimerMetadata(interval: interval.rawValue)
        let timer = Timer(&meta, value: self)
        nextItem = timer
        return timer.token
    }
    
    // MARK: - Overrides
    
    internal override func perform(_ value: Any, oldValue: Any?) {
        // trigger chain
        nextItem?.perform(_value, oldValue: oldValue)
    }
}
