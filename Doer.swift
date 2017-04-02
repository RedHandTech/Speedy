//
//  Doer.swift
//  Speedy
//
//  Created by Robert Sanders on 02/04/2017.
//  Copyright © 2017 Red Hand Technologies. All rights reserved.
//

internal class Doer<T>: Inspectable<T> {
    
    // MARK: - Private
    
    fileprivate let performer: (T) -> (T)
    
    // MARK: - Constructors
    
    init(performer: @escaping (T) -> (T)) {
        self.performer = performer
    }
    
    // MARK: - Overrides
    
    override internal func perform(_ value: Any, oldValue: Any?) {
        guard let val = value as? T else { return }
        let newVal = performer(val)
        nextItem?.perform(newVal, oldValue: oldValue)
    }
    
}
