//
//  Monitor.swift
//  Speedy
//
//  Created by Robert Sanders on 18/02/2017.
//  Copyright © 2017 Red Hand Technologies. All rights reserved.
//

internal class Monitor<T>: Inspectable<T> {
    
    // MARK: - Private
    
    fileprivate var callback: ((T) -> ())?
    
    // MARK: - Constructors
    
    internal init(callback: @escaping (T) -> ()) {
        super.init()
        self.callback = callback
    }
    
    // MARK: - Overrides
    
    internal override func perform(_ value: Any) {
        
        guard let val = value as? T else { return }
        
        callback?(val)
        nextItem?.perform(with: val)
    }
}
