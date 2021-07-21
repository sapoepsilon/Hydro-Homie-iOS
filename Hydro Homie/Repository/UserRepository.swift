//
//  UserRepository.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/6/21.
//

import Foundation
import Firebase



class UserRepository: ObservableObject {
    
    @Published var loggedIn: Bool = false
    var userID = ""
    
    func checkUser() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
            self.loggedIn = true
          } else {
            self.loggedIn = false
          }
        }
    }
    
    func signInUser(email: String, password: String, onSucces: @escaping() -> Void, onError: @escaping (_ errorMessage : String) -> Void ) {
        Auth.auth().signIn(withEmail: email, password: password) { (authData, error) in

                if (error != nil) {
                    print(error!.localizedDescription)
                    onError(error!.localizedDescription)
                    return
                } else {
                    self.userID = (authData?.user.uid)!
                    print(self.userID)
                    UserDefaults.standard.set(self.userID, forKey: "userID")
                    self.loggedIn = true
                }
        }
    }
    func signUpUser(email: String, password: String, name: String, weight: Double, height: Double, metric: Bool, waterIntake: Double, onSucces: @escaping() -> Void, onError: @escaping (_ errorMessage : String) -> Void ) {
        
        Auth.auth().createUser(withEmail: email, password: password) { [self](authData, error) in
            if (error != nil) {
                print(error!.localizedDescription)
                onError(error!.localizedDescription)
                return
            } else {
                self.userID = (authData?.user.uid)!
                print(self.userID)
                UserDefaults.standard.set(self.userID, forKey: "userID")
                
                addUserInformation(name: name, weight: weight, height: height, userID: self.userID, metric: metric, waterIntake: waterIntake)

            }
        }
    }
    
    func getUserID() -> String {
        var currentUserID = UserDefaults.standard.object(forKey: "userID") as! String
        if(currentUserID != "") {
            print("getting the userID from the device storage \(currentUserID)")
            return currentUserID
        }else {
            print("getting the userID from the Firebase \(currentUserID)")
	            currentUserID = Auth.auth().currentUser!.uid
            return currentUserID
        }
     }
    
    func signOut() {
       try! Auth.auth().signOut()
    }
    
    func addUserInformation(name: String, weight: Double, height: Double, userID: String, metric: Bool, waterIntake: Double) {
        print("userID before adding it \(userID)")
        Firestore.firestore().collection("users").document(userID).setData([
           "userID": userID,
            "name": name,
            "weight": weight,
            "height": height,
            "metric": metric,
            "waterIntake": waterIntake
        ])
        
        //MARK: USERDEFAULTS: user infromation
        let userInfo: User = User(name: name, height: Int(height), weight: weight, metric: metric, waterIntake: waterIntake, hydration: [])
        
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode Note
            let data = try encoder.encode(userInfo)
            
            print(data)
            // Write/Set Data
            UserDefaults.standard.set(data, forKey: "userInformation")

        } catch {
            print("Unable to Encode Note (\(error))")
        }
        // add the user information into UserDefaults
    }
    

}
