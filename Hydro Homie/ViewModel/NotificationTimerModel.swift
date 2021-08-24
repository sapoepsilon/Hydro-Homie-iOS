//
//  NotificationTimerModel.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 8/22/21.
//

import Foundation

var notificationTimerdisabledWhenNotActive = false

class NotificationTimerViewModel: ObservableObject {

    private enum SLTimerMode {
        case stopped
        case running
        case suspended
    }
    
    private weak var timer: Timer? = nil

    // these are internals of the timer.  when did it last start; when did it last
    // shut down; what state is it in; and how much time had it accumulated before
    // it last started up.
    private var previouslyAccumulatedTime: TimeInterval = 0.0
    private var startDate: Date? = nil
    private var lastStopDate: Date? = nil
    private var state: SLTimerMode = .stopped
    private var timerInterval: TimeInterval?
 
    // this is what people need to see: its accumulated time, which is the sum of
    // any accumulated time plus any current run time.  it gets updated by the timer
    // while running every second, which causes a subscriber to see the update.
    @Published var totalAccumulatedTime: TimeInterval = 0

    // now we let people ask us questions or tell us to do things
    var isSuspended: Bool { return state == .suspended }
    var isRunning: Bool { return state == .running }
    var isStopped: Bool { return state == .stopped }
    
    func defineTimeInterval(timeInterval: TimeInterval) {
        self.previouslyAccumulatedTime = timeInterval
        self.totalAccumulatedTime = timeInterval
        self.timerInterval = timeInterval
    }

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
        totalAccumulatedTime = timerInterval ?? 120
    }
    
}

var notificationTimeInterval = NotificationTimerViewModel()
