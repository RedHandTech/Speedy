//
//  Inspectable.swift
//  Speedy
//
//  Created by Robert Sanders on 18/02/2017.
//  Copyright © 2017 Red Hand Technologies. All rights reserved.
//

internal protocol Performer {
    
    func perform(_ value: Any, oldValue: Any?)
}

/// A class that defines actions that can be perfomed when an observed value is changed.
public class Inspectable<T>: Performer {
    
    // MARK: - Internal
    
    internal var nextItem: Performer?
    
    // MARK: - Private
    
    // MARK: - Internal
    
    internal func perform(_ value: Any, oldValue: Any?) {
        
    }
    
    // MARK: - <Inspectable>
    
    /// Appends a condition (predicate) to the observation chain.
    ///
    /// - Parameter predicate: The closure that defines the predicate
    /// - Returns: The next inspectable item in the observeration chain.
    public func when(_ predicate: @escaping (T) -> Bool) -> Inspectable<T> {
        
        let eval = Evaluator(performer: predicate)
        nextItem = eval
        return eval
    }
    
    /// Appends a mapping function to the observation chain.
    ///
    /// - Parameter mapper: A closure that maps a given value T to another, U.
    /// - Returns: The next inspectable item in the observation chain.
    public func map<U>(_ mapper: @escaping (T) -> U) -> Inspectable<U> {
        
        let trans = Transformer(performer: mapper)
        nextItem = trans
        return trans
    }
    
    /// Appends a comparison function to the observation chain.
    ///
    /// - Parameter predicate: A closure that compares and validates a value update with the previous one.
    /// - Returns: The next inspectable in the observation chain.
    public func compare(_ predicate: @escaping (T, T?) -> Bool) -> Inspectable<T> {
        
        let comp = Comparer(performer: predicate)
        nextItem = comp
        return comp
    }
    
    /// Appends a watch function to the observation chain. Used to observe values at any given place in the observation chain.
    ///
    /// - Parameter callback: A closure that will be triggered if the chain remains intact.
    /// - Returns: The next inspectable in the observation chain.
    public func watch(_ callback: @escaping (T) -> ()) -> Inspectable<T> {
        
        let mon = Monitor(callback: callback)
        nextItem = mon
        return mon
    }
    
    /// Appends an inspect function to the observation chain. This terminates the chain an no more operations can be perfomed for the current value update.
    ///
    /// - Parameter callback: A closure that will be triggered if the chain remains intact.
    public func inspect(_ callback: @escaping (T) -> ()) {
        
        let mon = Monitor(callback: callback)
        nextItem = mon
    }
}

public extension Inspectable where T: Equatable {
    
    /// Appends a comparison function to the observation chain that asserts that the new value is different from the previous one.
    ///
    /// - Returns: The next inspectable in the observation chain.
    public func distinct() -> Inspectable<T> {
        
        let comp = Comparer<T>(performer: { $0 != $1 })
        nextItem = comp
        return comp
    }
}





