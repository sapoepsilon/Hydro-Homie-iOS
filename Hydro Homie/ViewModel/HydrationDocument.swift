//
//  HydrationDocument.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/6/21.
//

import SwiftUI

class HydrationDocument: ObservableObject {
    
    @Published var document: HydrationModel = HydrationModel()
    
    func updateHydration(cups: Double, alcohol: Double?, coffee: Double?) {
        document.uploadCups(cups: cups, alcohol: alcohol, coffee: coffee)
    }
    
    func getCups(hydrationDictionary: [String: Dictionary<String, Double>], lastHydration: [String: Dictionary<String, Double>]) -> Double {
        return document.getCups(hydrationDictionary: hydrationDictionary, lastHydration: lastHydration)
    }
    
    func userID() -> String {
        document.getUserID()
    }
    
    func addNotification(timeInterval: Double) {
        
            // removing notifications
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
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

