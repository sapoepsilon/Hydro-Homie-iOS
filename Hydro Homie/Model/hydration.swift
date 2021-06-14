//
//  hydration.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/6/21.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

var enough: Bool = false
var newDate: Bool = false
let db = Firestore.firestore()
let cupsDate = Date()
let format = DateFormatter()
var arrayOfCups: [(Int, String)] = []

struct HydrationModel {
    
    func uploadCups(cups: Int) {
        enough = true
        format.dateFormat = "yyyy-MM-dd"
            let today = format.string(from: cupsDate)
        let hydrationByDay = [today: cups]
        print("users date: \(UserDefaults.standard.object(forKey: "today") as! String)")
        print("today's date: \(today)")

        if(UserDefaults.standard.object(forKey: "today") as! String != today) {
            print("users date: \(UserDefaults.standard.object(forKey: "today") as! String)")
            print("today's date: \(today)")

             db.collection("users").document(getUserID()).updateData([
                "hydration": FieldValue.arrayUnion([
                    hydrationByDay
                ])
             ])
        }
    }
    

    
    func getUserID() -> String {        
        let user =  UserDefaults.standard.object(forKey: "userID") as! String
        return user
    }
    
}
