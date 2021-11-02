//
//  NotificationTimer.swift
//  Hydro Comrade
//
//  Created by Ismatulla Mansurov on 8/22/21.
//

import SwiftUI

struct NotificationTimer: View {

    @Binding var timeInterval: TimeInterval
    @State var timeDistance: TimeInterval = 0
    @State var waterColor: Color = Color( red: 0, green: 0.5, blue: 0.8, opacity: 1)
    @State private var toxicityColor: Color = Color(red: 130 / 255, green: 98 / 255, blue: 222 / 255, opacity: 0.5)
    @ObservedObject var instoreTimer = notificationTimeInterval

    var body: some View {
            VStack {
                Text(timeString(accumulatedTime: instoreTimer.totalAccumulatedTime))
                    .font(.custom("Times", size: 36))
                    .foregroundColor(waterColor)
            }
            .onAppear {

                self.instoreTimer.defineTimeInterval(timeInterval: timeInterval)
                self.instoreTimer.start()
            }

            .onChange(of: timeInterval, perform: { value in
                self.instoreTimer.defineTimeInterval(timeInterval: timeInterval)

            })
    }
    
    func timeString(accumulatedTime: TimeInterval) -> String {
        let hours = Int(accumulatedTime) / 3600
        let minutes = Int(accumulatedTime) / 60 % 60
        let seconds = Int(accumulatedTime) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}

