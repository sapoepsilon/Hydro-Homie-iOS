//
//  HydrationDocument.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/6/21.
//

import SwiftUI

class HydrationDocument: ObservableObject {
    
    @Published var document: HydrationModel = HydrationModel()
    
    func updateHydration(cups: Double) {
        document.uploadCups(cups: cups)
    }
    
    func getCups(hydrationDictionary: [String: Double], lastHydration: [String: Double]) -> Double {
        return document.getCups(hydrationDictionary: hydrationDictionary, lastHydration: lastHydration)
    }
    
    func userID() -> String {
        document.getUserID()
    }
    
    func requestNotifiactionPermission() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func addNotification(timeInterval: Double) {
        
            // removing notifications
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            print("time interval: \(timeInterval)")
            let content = UNMutableNotificationContent()
            content.title = "Time to hydrate"
            content.subtitle = "Have one more cup of water"
            content.sound = UNNotificationSound.default

            // show this notification five seconds from now
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

            // choose a random identifier
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            // add our notification request
            UNUserNotificationCenter.current().add(request)
        
    }
}

