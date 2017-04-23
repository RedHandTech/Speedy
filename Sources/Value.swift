//
//  Value.swift
//  Speedy
//
//  Created by Robert Sanders on 18/02/2017.
//  Copyright © 2017 Red Hand Technologies. All rights reserved.
//

/// A class that wraps any value. This class provides the starting point for value observation with Speedy.
public class Value<T>: Inspectable<T> {
    
    // MARK: - Public
    
    /// The raw value currently held by the class.
    public var value: T {
        get {
            return _value
        } set {
            oldValue = value
            _value = newValue
        }
    }
    
    /// The previous value. Starting value is nil.
    private(set) public var oldValue: T?
    
    // MARK: - Private
    
    fileprivate var _value: T {
        didSet {
            perform(_value, oldValue: oldValue)
        }
    }
    
    // MARK: - Constructors
    
    /// Creates a new instance of Value.
    ///
    /// - Parameter value: The value to wrap.
    public init(_ value: T) {
        _value = value
    }
    
    // MARK: - Overrides
    
    internal override func perform(_ value: Any, oldValue: Any?) {
        // trigger chain
        nextItem?.perform(_value, oldValue: oldValue)
    }
}





