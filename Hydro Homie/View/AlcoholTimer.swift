//
//  AlcoholTimer.swift
//  AlcoholTimer
//
//  Created by Ismatulla Mansurov on 7/20/21.
//

import SwiftUI

struct AlcoholTimer: View {
    
    @Binding var isDiureticMode: Bool
    @Binding var waterColor: Color
    @State private var toxicityColor: Color = Color(red: 130 / 255, green: 98 / 255, blue: 222 / 255, opacity: 0.5)
    @ObservedObject var instoreTimer = timerBackground
    

    var body: some View {
            VStack {
                Text(timeString(accumulatedTime: instoreTimer.totalAccumulatedTime))
                    .font(.custom("Times", size: 36))
                    .foregroundColor(isDiureticMode ? toxicityColor : waterColor)
            }
            .onAppear { print("TimerTabView appear")
                self.instoreTimer.start()
            }
            .onDisappear {
                print("TimerTabView disappear")
            }
         
    }
    
    func timeString(accumulatedTime: TimeInterval) -> String {
        let hours = Int(accumulatedTime) / 3600
        let minutes = Int(accumulatedTime) / 60 % 60
        let seconds = Int(accumulatedTime) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }

}
