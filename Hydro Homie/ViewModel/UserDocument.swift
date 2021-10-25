//
//  UserDocument.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/9/21.
//

import Foundation
import Firebase
import CoreLocation

class UserDocument: ObservableObject {

    let db = Firestore.firestore()
    let today = Date()
    var locationManager: CLLocationManager?
    @Published var user: User = User(name: "", height: 1, weight: 1, metric: false, isCoffeeDrinker: false, waterIntake: 1, hydration: [["": ["water": 0.0, "alcohol": 0.0, "coffee": 0.0]]], userUID: "")

    enum documentExist {
        case exist
        case doesNotExist
    }

    @Published var enumDocument: documentExist = documentExist.exist

    func fetchData() {
        //check if the user has a new device
        // if not the return values from UserDefaults

        let currentUserID = Auth.auth().currentUser?.uid
        print("userdID \(String(describing: currentUserID))")

        db.collection("users").document(currentUserID!).addSnapshotListener { (querySnapshot, error) in
            if (error != nil) {
                print(error!.localizedDescription)
                return
            } else if (querySnapshot!.data() != nil) {
                let document = querySnapshot!.data()
                self.user.name = document!["name"] as? String ?? ""
                self.user.height = document!["height"] as? Int ?? 1
                self.user.weight = document!["weight"] as? Double ?? 1
                self.user.metric = document!["metric"] as? Bool ?? false
                self.user.waterIntake = document!["waterIntake"] as? Double ?? 1
                self.user.hydration = document!["hydration"] as? [[String: Dictionary<String, Double>]] ?? [["": ["water": 0, "alcohol": 0, "coffee": 0]]]
                self.saveHydrationDictionaryToUserDefaults(hydrationInTheLoop: self.user.hydration)
                self.user.isCoffeeDrinker = document!["isCoffeeDrinker"] as? Bool ?? false
                self.user.userUID = document!["userID"] as? String ?? ""
                self.enumDocument = .exist
            } else if (querySnapshot?.exists == nil) {
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
        for (_, _) in lastItem ?? [today: ["water": 0, "alcohol": 0, "coffee": 0]] {
            currentDate = lastItem?.keys.first! ?? ""
        }
        return currentDate
    }

    func changeData(userID: String, name: String?, weight: Double?, height: Double?, isMetric: Bool, isCoffeeDrinker: Bool, waterIntake: Double) -> String {
        //TODO: calculate water Intake

        var returnMessage = "Written successfully"
        let updatedFields: [String: Any] = [
            "name": name as Any,
            "weight": weight as Any,
            "height": height as Any,
            "metric": isMetric,
            "waterIntake": waterIntake,
            "isCoffeeDrinker": isCoffeeDrinker
        ]
        db.collection("users").document(userID).setData(updatedFields, merge: true, completion: { error in
            if error != nil {
                returnMessage = error!.localizedDescription
            }
        })
        return returnMessage
    }

    func changeEmail(email: String, completionHandler: @escaping (Bool, String) -> Void) {
        Auth.auth().currentUser?.updateEmail(to: email, completion: { error in
            if error != nil {
                print("error \(error.debugDescription)")
                completionHandler(false, error?.localizedDescription ?? "Error has occured, please try again!")
            } else {
                completionHandler(true, "Email has benn updated successfully.")
                print("updated successfully")
            }
        })
    }

    func changeCredentials(newPassword: String?, completionHandler: @escaping (Bool, String) -> Void) {
        Auth.auth().currentUser?.updatePassword(to: newPassword!, completion: { error in
            if error != nil {
                completionHandler(false, error?.localizedDescription ?? "Error has occured please try again!")
            } else {
                completionHandler(true, "Password has been updated")
            }
        })
        
    }

    func previousDate(hydrationArray: [String: Dictionary<String, Double>]) -> [String: Dictionary<String, Double>] {
        var previousDate: [String: Dictionary<String, Double>] = ["": ["": 0]]
        var arrayElementNumber: Int = 0
        for element in user.hydration {
            if element == hydrationArray {
                if (element == user.hydration.first) {
                    previousDate = element
                    return previousDate
                } else {
                    previousDate = user.hydration[arrayElementNumber - 1]
                    return previousDate
                }
            }
            arrayElementNumber += 1
        }
        print("previous date: \(previousDate)")
        return previousDate
    }

    func saveHydrationDictionaryToUserDefaults(hydrationInTheLoop: [[String: [String: Double]]]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(hydrationInTheLoop)
            UserDefaults.standard.set(data, forKey: "hydration")
        } catch {
            print("Unable to Encode hydration Array (\(error))")
        }
        if let data = UserDefaults.standard.data(forKey: "hydration") {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()
                do {
                    print("Hydration in the userdefaults after saving to it: \(try decoder.decode([[String: [String: Double]]].self, from: data).description)")
                } catch {
                    print("Unable to Decode hydration after saving it(\(error))")
                }
            }
        }
    }

    func getHydrationArrayFromTheUserDefaults() -> [[String: [String:Double]]] {
        var returnValue: [[String: [String: Double]]] = []
        if let data = UserDefaults.standard.data(forKey: "hydration") {
            do {
                let decoder = JSONDecoder()
                returnValue = try decoder.decode([[String: [String: Double]]].self, from: data)
            } catch {
                print("Unable to Decode hydration (\(error))")
            }
        }
        return returnValue
    }

    func updateHydrationDictionaryInUserDefaults(currentHydration: [String: [String: Double]], newHydrationValues: [String: Double], key: String) {
        var arrayOfHydration = getHydrationArrayFromTheUserDefaults()

        for hydration in arrayOfHydration {
            if hydration.keys == currentHydration.keys {
                let index = arrayOfHydration.firstIndex(of: hydration)
                arrayOfHydration[index!].updateValue(newHydrationValues, forKey: key)
            }
        }
        saveHydrationDictionaryToUserDefaults(hydrationInTheLoop: arrayOfHydration)
    }

    func nextDate(hydrationArray: [String: Dictionary<String, Double>]) -> [String: Dictionary<String, Double>] {
        var previousDate: [String: Dictionary<String, Double>] = ["": ["": 0]]
        var arrayElementNumber: Int = 0

        for element in user.hydration {
            if element == hydrationArray {
                if (element == user.hydration.last) {
                    previousDate = element
                    return previousDate
                } else {
                    previousDate = user.hydration[arrayElementNumber + 1]
                    return previousDate
                }
            }
            arrayElementNumber += 1
        }
        return previousDate
    }


}




