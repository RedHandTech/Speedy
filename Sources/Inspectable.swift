//
//  Inspectable.swift
//  Speedy
//
//  Created by Robert Sanders on 18/02/2017.
//  Copyright © 2017 Red Hand Technologies. All rights reserved.
//

internal protocol Performer {
    
    func perform(_ value: Any)
}

public class Inspectable<T>: Performer {
    
    // MARK: - Internal
    
    // MARK: - Private
    
    internal var nextItem: Performer?
    
    // MARK: - Internal
    
    internal func perform(_ value: Any) {
        
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
