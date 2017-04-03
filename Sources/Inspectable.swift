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

public class Inspectable<T>: Performer {
    
    // MARK: - Internal
    
    // MARK: - Private
    
    internal var nextItem: Performer?
    
    // MARK: - Internal
    
    internal func perform(_ value: Any, oldValue: Any?) {
        
    }
    
    // MARK: - <Inspectable>
    
    public func when(_ predicate: @escaping (T) -> Bool) -> Inspectable<T> {
        
        let eval = Evaluator(performer: predicate)
        nextItem = eval
        return eval
    }
    
    public func map<U>(_ mapper: @escaping (T) -> U) -> Inspectable<U> {
        
        let trans = Transformer(performer: mapper)
        nextItem = trans
        return trans
    }
    
    public func compare(_ predicate: @escaping (T, T?) -> Bool) -> Inspectable<T> {
        
        let comp = Comparer(performer: predicate)
        nextItem = comp
        return comp
    }
    
    public func watch(_ callback: @escaping (T) -> ()) -> Inspectable<T> {
        
        let mon = Monitor(callback: callback)
        nextItem = mon
        return mon
    }
    
    public func inspect(_ callback: @escaping (T) -> ()) {
        
        let mon = Monitor(callback: callback)
        nextItem = mon
    }
}

public extension Inspectable where T: Equatable {
    
    public func distinct() -> Inspectable<T> {
        
        let comp = Comparer<T>(performer: { $0 != $1 })
        nextItem = comp
        return comp
    }
}





