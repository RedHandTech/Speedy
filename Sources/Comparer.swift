//
//  Comparer.swift
//  Speedy
//
//  Created by Robert Sanders on 12/03/2017.
//  Copyright © 2017 Red Hand Technologies. All rights reserved.
//

internal class Comparer<T>: Inspectable<T> {
    
    // MARK: - Private
    
    fileprivate let perfomer: (T, T?) -> Bool
    
    // MARK: - Constructors
    
    internal init(performer: @escaping (T, T?) -> Bool) {
        self.perfomer = performer
    }
    
    // MARK: - Override
    
    internal override func perform(_ value: Any, oldValue: Any?) {
        
        guard let val = value as? T else { return }
        guard perfomer(val, oldValue as? T) else { return }
        nextItem?.perform(val, oldValue: oldValue)
    }
}
