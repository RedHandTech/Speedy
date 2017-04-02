//
//  Timer.swift
//  Speedy
//
//  Created by Robert Sanders on 01/04/2017.
//  Copyright © 2017 Red Hand Technologies. All rights reserved.
//

import Foundation

internal class TimerToken<T>: Inspectable<T> {
    
    // MARK: - Private
    
    fileprivate var timer: Timer<T>
    
    // MARK: - Construtors
    
    fileprivate init(timer: Timer<T>) {
        self.timer = timer
    }
    
    // MARK: - Public
    
    override func when(_ predicate: @escaping (T) -> Bool) -> Inspectable<T> {
        setupTimer()
        let ne = super.when(predicate)
        self.timer.nextItem = ne
        return ne
    }
    
    override func map<U>(_ mapper: @escaping (T) -> U) -> Inspectable<U> {
        setupTimer()
        let ne = super.map(mapper)
        self.timer.nextItem = ne
        return ne
    }
    
    override func compare(_ predicate: @escaping (T, T?) -> Bool) -> Inspectable<T> {
        setupTimer()
        let ne = super.compare(predicate)
        self.timer.nextItem = ne
        return ne
    }
    
    override func watch(_ callback: @escaping (T) -> ()) -> Inspectable<T> {
        setupTimer()
        let ne = super.watch(callback)
        self.timer.nextItem = ne
        return ne
    }
    
    public override func `do`(_ perfomer: @escaping (T) -> (T)) -> Inspectable<T> {
        self.timer.peformer = perfomer
        let ne = Doer<T>(performer: { $0 })
        self.timer.nextItem = ne
        return ne
    }
    
    override func inspect(_ callback: @escaping (T) -> ()) {
        setupTimer()
        let mon = Monitor(callback: callback)
        self.timer.nextItem = mon
    }
    
    // MARK: - Private
    
    func setupTimer() {
        self.timer.peformer = { $0 }
    }
}

/// Speedy Timer metadata
public struct TimerMetadata {
    
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
    fileprivate let startImmidiately: Bool
    
    fileprivate var timerNotifier: (() -> ())?
    
    // MARK: - Constructors
    
    /// Initialises new TimerToken with given interval value and default parameters.
    ///
    /// - Parameter interval: Time interval between updates in seconds
    init(interval: Float) {
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
        self.startImmidiately = startImmidiately ?? true
    }
    
    // MARK: - Public
    
    /// Starts the timer if in the paused or stop state.
    mutating func start() {
        
        guard !isRunning else { return }
        
        isRunning = true
        timerNotifier?()
    }
    
    /// Pauses the timer. Count is not cleared.
    mutating func pause() {
     
        isRunning = false
    }
    
    /// Stops the timer (clears the count).
    mutating func stop() {
        
        isRunning = false
        count = 0
    }
    
    // MARK: - Private
    
    fileprivate mutating func tick() {
        
        count += 1
    }
}

public enum Time: Float {
    case second = 1
    case minute = 60
}

internal class Timer<T>: Inspectable<T> {
    
    // MARK: - Internal
    
    internal var token: TimerToken<T> {
        get {
            if _token == nil {
                _token = TimerToken(timer: self)
            }
            return _token!
        }
    }
    
    // MARK: - Private
    
    fileprivate var metadata: TimerMetadata
    fileprivate let value: Value<T>
    fileprivate var peformer: ((T) -> (T))?
    
    fileprivate var _token: TimerToken<T>?
    
    // MARK: - Constructors
    
    internal init(_ metadata: inout TimerMetadata, value: Value<T>) {
        
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
        
        guard metadata.startImmidiately else { return }
        
        if !metadata.usesGCD {
            let thread = Thread(target: self, selector: #selector(tick), object: nil)
            thread.start()
        } else {
            let queue = DispatchQueue(label: "com.Speedy.SerialQueue")
            weak var welf = self
            queue.async {
                welf?.tick()
            }
        }
    }
    
    @objc fileprivate func tick() {
        
        if metadata.count == 0 && metadata.delays {
            // is starting so need to delay
            Thread.sleep(forTimeInterval: TimeInterval(metadata.interval))
        }
        
        while metadata.isRunning {
            
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
    
    // MARK: - Override
    
    internal override func perform(_ value: Any, oldValue: Any?) {
        
        nextItem?.perform(value, oldValue: oldValue)
    }
    
}




















