//
//  Transformer.swift
//  Speedy
//
//  Created by Robert Sanders on 18/02/2017.
//  Copyright © 2017 Red Hand Technologies. All rights reserved.
//

internal class Transformer<T, U>: Inspectable<U> {
    
    // MARK: - Private
    
    fileprivate let performer: (T) -> U
    
    // MARK: - Constructors
    
    internal init(performer: @escaping (T) -> U) {
        self.performer = performer
    }
    
    // MARK: - Overrides
    
    internal override func perform(_ value: Any, oldValue: Any?) {
        
        guard let val = value as? T else { return }
        
        var oldVal: U?
        if let ov = oldValue as? T {
            oldVal = performer(ov)
        }
        
        let newVal = performer(val)
        
        nextItem?.perform(newVal, oldValue: oldVal)
    }
}
