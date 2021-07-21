//
//  AlcoholTimer.swift
//  AlcoholTimer
//
//  Created by Ismatulla Mansurov on 7/20/21.
//

import SwiftUI

struct AlcoholTimer: View {
    @State private var hours: Int = 3
    @State private var minutes: Int = 59
    @State private var seconds: Int = 59
    @State private var timerIsPaused: Bool = true
    @State private var timer: Timer? = nil
    @Binding  var isTimer: Bool
    var body: some View {
        VStack {
            if isTimer {
                Text("Alcohol period")
                Text("\(hours):\(minutes):\(seconds)")
            }
        }.onAppear(perform: {
            if isTimer {
                startTimer()
            }
        })
    }
    
    func startTimer(){
        timerIsPaused = false
        // 1. Make a new timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ tempTimer in
            // 2. Check time to add to H:M:S
            if self.seconds == 0 {
                self.seconds = 59
                if self.minutes == 0 {
                    self.minutes = 59
                    self.hours = self.hours - 1
                } else {
                    self.minutes = self.minutes - 1
                }
            } else {
                self.seconds = self.seconds - 1
            }
            
            if self.seconds == 0 && self.minutes == 0 && self.hours == 0 {
                self.isTimer = false
            }
        }
    }
    
    func stopTimer(){
        timerIsPaused = true
        timer?.invalidate()
        timer = nil
    }
    
}
