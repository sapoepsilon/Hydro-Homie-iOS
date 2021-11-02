//
//  hydration.swift
//  Hydro Comrade
//
//  Created by Ismatulla Mansurov on 6/6/21.
//

import Foundation
import Firebase
import FirebaseAuth

var enough: Bool = false
var newDate: Bool = false
var db = Firestore.firestore()
let cupsDate = Date()
let format = DateFormatter()
var arrayOfCups: [(Int, String)] = []


struct HydrationModel {
    
    func uploadCups(cups: Double, alcohol: Double?, coffee: Double?) {
        enough = true
        format.dateFormat = "MMM d, yyyy"
        let today = format.string(from: cupsDate)
        let hydrationDictionary = ["water" : cups, "alcohol" : alcohol, "coffee" : coffee]
        let hydrationByDay = [
            today: hydrationDictionary
        ]

        if(UserDefaults.standard.string(forKey: "today") != today) {

            db.collection("users").document(getUserID()).setData([
                "hydration": FieldValue.arrayUnion([
                    hydrationByDay
                ])
            ], merge: true)
            
            UserDefaults.standard.setValue(today, forKey: "today")
            //TODO: add the new data into userdefaults 
        } else {
            
        }
    }
    
    func getCups(hydrationDictionary: [String: Dictionary<String, Double>], lastHydration: [String: Dictionary<String, Double>]) -> Double {
        format.dateFormat = "MMM d, yyyy"
        let today = format.string(from: cupsDate)
        print("Date of todat in the document \(today)")
        if hydrationDictionary == lastHydration {
            if(UserDefaults.standard.string(forKey: "today") == today) {
                let lastCup = UserDefaults.standard.double(forKey: "cups")
                
                return lastCup
            } else {
                return waterPercentageCalculator(hydrationDictionary: hydrationDictionary)
            }
        } else {
            return waterPercentageCalculator(hydrationDictionary: hydrationDictionary)
        }

    }

    func waterPercentageCalculator(hydrationDictionary: [String: Dictionary<String, Double>]) -> Double {
        let currentHydration = hydrationDictionary
        var currentCups: Double = 1
        for drinks in  currentHydration.values {
            currentCups = drinks["water"] ?? 0
        }
        return currentCups
    }
    
    func getUserID() -> String {
        var user: String = ""
        if (UserDefaults.standard.object(forKey: "userID") as? String != nil) {
            user = (UserDefaults.standard.object(forKey: "userID") as? String)!
        } else {
            user = FirebaseAuth.Auth.auth().currentUser!.uid
        }
        return user
    }
    
    
}
