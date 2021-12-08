//
//  HydrationDocument.swift
//  Hydro Comrade
//
//  Created by Ismatulla Mansurov on 6/6/21.
//

import SwiftUI

class HydrationDocument: ObservableObject {
    
    @Published var document: HydrationModel = HydrationModel()
    
    func updateHydration(hydration: FetchedResults<LocalHydration>) {
        
        let hydrationTodayID = hydration.last?.id ?? 1
        var hydrationPreviousDay = hydration.last
        for hydro in hydration {
            print("hydration id in the loop \(hydro)")
            if hydro.id == hydrationTodayID - 1 {
                hydrationPreviousDay = hydro
            }
        }

        document.uploadCups(cups: hydrationPreviousDay!.water, alcohol: hydrationPreviousDay!.alcohol, coffee: hydrationPreviousDay!.coffee, date: hydrationPreviousDay?.date ?? "error")
    }
    
    func updateHydrationLocally(hydration: [[String: [String:Double]]]) {
        
    }
    

    
    func userID() -> String {
        document.getUserID()
    }
    
    func addNotification(timeInterval: Double) {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            let content = UNMutableNotificationContent()
            content.title = "Time to hydrate"
            content.subtitle = "Have one more cup of water"
            content.sound = UNNotificationSound.default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request)
        
    }
    
    func removeNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

