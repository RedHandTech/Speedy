//
//  Timer.swift
//  Speedy
//
//  Created by Robert Sanders on 01/04/2017.
//  Copyright © 2017 Red Hand Technologies. All rights reserved.
//

import Foundation

/// Speedy Timer metadata
public class TimerMetadata {
    
    // MARK: - Public
    
    /// Number of updates called so far.
    fileprivate(set) var count = 0
    
    /// Whether the timer is currently running.
    fileprivate(set) var isRunning: Bool = true
    
    // MARK: - Private
    
    fileprivate let interval: Float
    fileprivate let delays: Bool
    fileprivate let updatesOnMainThread: Bool
    fileprivate let usesGCD: Bool
    
    fileprivate var timerNotifier: (() -> ())?
    fileprivate var shouldDelay: Bool = false
    
    // MARK: - Constructors
    
    /// Initialises new TimerToken with given interval value and default parameters.
    ///
    /// - Parameter interval: Time interval between updates in seconds
    convenience init(interval: Float) {
        self.init(interval: interval, delays: true, updatesOnMainThread: true, usesGCD: true, startImmidiately: true)
    }
    
    /// Initialises new TimerToken with given values.
    ///
    /// - Parameters:
    ///   - interval: Time interval between updates in seconds
    ///   - delays: Whether there is an interval delay between starting and the first udpdate call. Default is true.
    ///   - updatesOnMainThread: Whether the update is called on the main thread. Default is true.
    ///   - usesGCD: Whether the timer uses GCD. Default is true. False uses NSThread.
    init(interval: Float, delays: Bool?, updatesOnMainThread: Bool?, usesGCD: Bool?, startImmidiately: Bool?) {
        self.interval = interval
        self.delays = delays ?? true
        self.updatesOnMainThread = updatesOnMainThread ?? true
        self.usesGCD = usesGCD ?? true
        self.isRunning = startImmidiately ?? true
        
        self.shouldDelay = self.delays
    }
    
    // MARK: - Public
    
    /// Starts the timer if in the paused or stop state.
    func start() {
        
        guard !isRunning else { return }
        
        isRunning = true
        timerNotifier?()
    }
    
    /// Pauses the timer. Count is not cleared.
    func pause() {
     
        isRunning = false
        self.shouldDelay = true
    }
    
    /// Stops the timer (clears the count).
    func stop() {
        
        isRunning = false
        count = 0
        self.shouldDelay = self.delays
    }
    
    // MARK: - Private
    
    fileprivate func tick() {
        
        count += 1
    }
}

public enum Time: Float {
    case second = 1
    case minute = 60
}

internal class Timer<T>: Inspectable<T> {
    
    // MARK: - Internal
    
    internal var peformer: ((T) -> (T))?
    
    // MARK: - Private
    
    fileprivate var metadata: TimerMetadata
    fileprivate let value: Value<T>
    
    // keep refeference to all running threads so that only one runs at a time
    fileprivate var threadRunning: [UUID: Bool] = [:]
    
    // MARK: - Constructors
    
    internal init(_ metadata: TimerMetadata, value: Value<T>) {
        
        self.metadata = metadata
        self.value = value
        
        super.init()
        
        weak var welf = self
        metadata.timerNotifier = {
            welf?.start()
        }
        
        if metadata.isRunning {
            start()
        }
    }
    
    // MARK: - Private
    
    fileprivate func start() {
        
        clearRunningThreads()
        
        let threadID = UUID()
        threadRunning[threadID] = true
        
        if !metadata.usesGCD {
            let thread = Thread(target: self, selector: #selector(tick), object: threadID)
            thread.start()
        } else {
            let queue = DispatchQueue(label: "com.Speedy.SerialQueue")
            weak var welf = self
            queue.async {
                welf?.tick(id: threadID)
            }
        }
    }
    
    @objc fileprivate func tick(id: UUID) {
        
        if metadata.shouldDelay {
            Thread.sleep(forTimeInterval: TimeInterval(metadata.interval))
        }
        
        while metadata.isRunning {
            
            // check this thread is still supposed to be running
            if threadRunning[id] != true {
                return
            }
            
            // use performer to update the value's value
            if metadata.updatesOnMainThread {
                weak var welf = self
                DispatchQueue.main.async {
                    guard let welf = welf else { return }
                    welf.value.value = welf.peformer?(welf.value.value) ?? welf.value.value
                }
            } else {
                value.value = peformer?(value.value) ?? value.value
            }
            
            // update the metadata
            metadata.tick()
            // sleep the thread
            Thread.sleep(forTimeInterval: TimeInterval(metadata.interval))
        }
    }
    
    fileprivate func clearRunningThreads() {
    
        for key in threadRunning.keys {
            threadRunning[key] = false
        }
    }
    
    // MARK: - Override
    
    internal override func perform(_ value: Any, oldValue: Any?) {
        
        nextItem?.perform(value, oldValue: oldValue)
    }
    
}


















