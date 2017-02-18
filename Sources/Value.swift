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
            _value = newValue
        }
    }
    
    // MARK: - Private
    
    fileprivate var _value: T {
        didSet {
            perform(with: _value)
        }
    }
    
    // MARK: - Constructors
    
    public init(_ value: T) {
        _value = value
    }
    
    // MARK: - Overrides
    
    internal override func perform(_ value: Any) {
        // trigger chain
        nextItem?.perform(with: _value)
    }
}
