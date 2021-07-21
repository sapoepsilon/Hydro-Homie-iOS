//
//  UserDocument.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/9/21.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

class UserDocument: ObservableObject {
    
    let db = Firestore.firestore()
    let today = Date()
    var locationManager: CLLocationManager?
    @Published var user: User = User(name: "", height: 1, weight: 1, metric: false, waterIntake: 1,  hydration:  [["": 1]])
    
    
    func fetchData() {
        
        //check if the user has a new device
        
        // if not the return values from UserDefaults
        
        let currentUserID = Auth.auth().currentUser?.uid

        db.collection("users").document(currentUserID!).addSnapshotListener { (querySnapshot, error) in
            if (error != nil) {
                print(error!.localizedDescription)
                return
            }   else if(querySnapshot!.data() != nil) {
                let document = querySnapshot!.data()
                self.user.name = document!["name"] as? String ?? ""
                self.user.height = document!["height"] as? Int ?? 1
                self.user.weight = document!["Weight"] as? Double ?? 1
                self.user.metric = document!["metric"] as? Bool ?? false
                self.user.waterIntake = document!["waterIntake"] as? Double ?? 1
                self.user.hydration = document!["hydration"] as? [[String: Int]] ??  [["": 1]]
            }
        }
    }
    
    
    
    func getUser() -> User {
        let user = user
        return user
    }
    
    func getTheLatestDate() -> String {
        // MARK: change to core data
        let lastItem = user.hydration.last
        var currentDate: String = ""
        for (date, _) in  lastItem! {
            currentDate = date
            UserDefaults.standard.setValue(date, forKey: "today")
            
        }
        return currentDate
    }


    func waterPercentageCalculator(hydrationDictionary: [String: Int]) -> Int{
        let currentHydration = hydrationDictionary
        var currentCups: Int = 1
        for (_, cups) in  currentHydration {
            currentCups = cups
        }
        return currentCups
    }


    func previousDate(hydrationArray: [String: Int]) -> [String: Int] {
        var previousDate: [String: Int] = ["":0]
        var arrayElementNumber: Int = 0
        for element in user.hydration {
            if element == hydrationArray {
                if (element == user.hydration.first) {
                    previousDate  = element
                    return previousDate
                } else {
                    previousDate =  user.hydration[arrayElementNumber-1]
                    return previousDate
                }
            }
            arrayElementNumber += 1
        }
        return previousDate
    }
    func nextDate(hydrationArray: [String: Int]) -> [String: Int] {
        var previousDate: [String: Int] = ["":0]
        var arrayElementNumber: Int = 0
        
        for element in user.hydration {
            if element == hydrationArray {
                if (element == user.hydration.last) {
                    previousDate  = element
                    return previousDate
                } else {
                    previousDate =  user.hydration[arrayElementNumber+1]
                    print("previousDate \(previousDate)")
                    return previousDate
                }
            }
            arrayElementNumber += 1
        }
        
        return previousDate
    }
}




