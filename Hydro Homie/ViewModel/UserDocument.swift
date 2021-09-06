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
    @Published var user: User = User(name: "", height: 1, weight: 1, metric: false, isCoffeeDrinker: false, waterIntake: 1,  hydration:  [["": 1]], userUID: "")
    
    enum documentExist {
        case exist
        case doesNotExist
    }
    
    @Published var enumDocument: documentExist = documentExist.exist
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
                self.user.weight = document!["weight"] as? Double ?? 1
                self.user.metric = document!["metric"] as? Bool ?? false
                self.user.waterIntake = document!["waterIntake"] as? Double ?? 1
                self.user.hydration = document!["hydration"] as? [[String: Double]] ??  [["": 1]]
                self.user.isCoffeeDrinker = document!["isCoffeeDrinker"] as? Bool ?? false
                self.user.userUID = document!["userID"] as? String ?? ""
                self.enumDocument = .exist
            } else if(querySnapshot?.exists == nil) {
                self.enumDocument = .doesNotExist
            }

        }
    }
    
    
    
    func getUser() -> User {
        let user = user
        return user
    }
    
    func getTheLatestDate() -> String {
        // MARK: change to core data
        let cupsDate = Date()
        format.dateFormat = "yyyy-MM-dd"
        let today = format.string(from: cupsDate)
        let lastItem = user.hydration.last
        var currentDate: String = ""
        for (date, _) in  lastItem ?? [today : 0] {
            currentDate = date
        }
        return currentDate
    }


    func changeData(userID: String, name: String?, weight: Double?, height: Double?, isMetric: Bool, isCoffeeDrinker: Bool, waterIntake: Double) -> String {
        //TODO: calculate water Intake

        var returnMessage = "Written successfully"
        let updatedFields: [String:Any] = [
            "name": name as Any,
             "weight": weight,
             "height": height,
             "metric": isMetric,
             "waterIntake": waterIntake,
            "isCoffeeDrinker": isCoffeeDrinker
        ]
        print("userID \(userID)")
        db.collection("users").document(userID).setData(updatedFields, merge: true, completion: { error in
            if error != nil {
                returnMessage = error!.localizedDescription
            }
        })
        return returnMessage
    }
    
    func changeEmail(email: String) {
        Auth.auth().currentUser?.updateEmail(to: email, completion: { error in
            if error != nil {
                print ("error \(error.debugDescription)")
            } else {
                print("updated successfully")
            }
        })
    }
    func changeCredentials(newPassword: String?) -> String {
        var returnMessage = "Password has been updated"

            Auth.auth().currentUser?.updatePassword(to: newPassword!, completion: { error in
                if error != nil {
                   return  returnMessage = error!.localizedDescription
                } else {
                   return  returnMessage += "Password has been updated"
                }
            })
        return returnMessage
    }


    func previousDate(hydrationArray: [String: Double]) -> [String: Double] {
        var previousDate: [String: Double] = ["":0]
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
    
    func nextDate(hydrationArray: [String: Double]) -> [String: Double] {
        var previousDate: [String: Double] = ["":0]
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




