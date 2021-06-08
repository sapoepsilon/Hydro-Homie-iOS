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
    
    func countCups(cups: Int) {
        enough = true
        format.dateFormat = "yyyy-MM-dd"
        let today = format.string(from: cupsDate)
        let docData: [String: Any] = [
            "hydration": [cups, today]
        ]

         
             db.collection("users").document(getUserID()).setData([
                "hydration": FieldValue.arrayUnion([
                    docData
                ]),
                "userID": UserDefaults.standard.object(forKey: "userID") as! String
             ])
        print("document wrriten")
    }
    
    func getUserID() -> String {
        UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "userID")
        
        let user =  UserDefaults.standard.object(forKey: "userID") as! String
        
        print(user)
        return user
    }
    
}
