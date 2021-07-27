//
//  TimerBackground.swift
//  TimerBackground
//
//  Created by Ismatulla Mansurov on 7/20/21.
//

import Foundation


import Foundation


var kDisableTimerWhenAppIsNotActive = false

class TimerViewModel: ObservableObject {

    private enum SLTimerMode {
        case stopped
        case running
        case suspended
    }
    
    private weak var timer: Timer? = nil

    // these are internals of the timer.  when did it last start; when did it last
    // shut down; what state is it in; and how much time had it accumulated before
    // it last started up.
    private var previouslyAccumulatedTime: TimeInterval = 14
    private var startDate: Date? = nil
    private var lastStopDate: Date? = nil
    private var state: SLTimerMode = .stopped
            
    // this is what people need to see: its accumulated time, which is the sum of
    // any accumulated time plus any current run time.  it gets updated by the timer
    // while running every second, which causes a subscriber to see the update.
    @Published var totalAccumulatedTime: TimeInterval = 14

    // now we let people ask us questions or tell us to do things
    var isSuspended: Bool { return state == .suspended }
    var isRunning: Bool { return state == .running }
    var isStopped: Bool { return state == .stopped }

    private func shutdownTimer() {
        // how long we've been in the .running state
        let accumulatedRunningTime = Date().timeIntervalSince(startDate!)
        // total running time: however long we had been running before entering the
        // current .running state, plus how long we've now been running now
        previouslyAccumulatedTime += accumulatedRunningTime
        totalAccumulatedTime = previouslyAccumulatedTime

        // remember when we shut down
        lastStopDate = Date()
        // throw out the time
        timer!.invalidate()
        timer = nil  // should happen anyway with a weak variable
    }
    
    func suspend() {
        // it only makes sense to suspend if you are running
        if state == .running {
            shutdownTimer()
            state = .suspended
        }
    }
    
    func start() {
        if state != .running {
            
            startDate = Date()

            if state == .suspended && !kDisableTimerWhenAppIsNotActive {
                startDate = lastStopDate
            }
            // schedule a new timer
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(update)), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode:RunLoop.Mode.default)
            state = .running
        }
    }
    
    func stop() {
        // it only makes sense to stop if you are running
        if state == .running {
            shutdownTimer()
            state = .stopped
        }
    }
    
    @objc private func update() {
        // how long we've been running in the current .running state
        // and add in any previously accumulated time
        totalAccumulatedTime = previouslyAccumulatedTime - Date().timeIntervalSince(startDate!)
        if totalAccumulatedTime < 0.5 {
            stop()
        }
    }
    
    func reset() {
        guard state == .stopped else { return }
        previouslyAccumulatedTime = 0
        totalAccumulatedTime = 14400
    }
    
}

// global timer variable
var timerBackground = TimerViewModel()
