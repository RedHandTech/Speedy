//
//  Evaluator.swift
//  Speedy
//
//  Created by Robert Sanders on 18/02/2017.
//  Copyright © 2017 Red Hand Technologies. All rights reserved.
//

internal class Evaluator<T>: Inspectable<T> {
    
    // MARK: - Private
    
    fileprivate let performer: (T) -> Bool
    
    // MARK: - Constructors
    
    internal init(performer: @escaping (T) -> Bool) {
        self.performer = performer
    }
    
    // MARK: - Override
    
    internal override func perform(_ value: Any) {
        
        guard let val = value as? T else { return }
        
        guard performer(val) else { return }
        nextItem?.perform(with: val)
    }
}
