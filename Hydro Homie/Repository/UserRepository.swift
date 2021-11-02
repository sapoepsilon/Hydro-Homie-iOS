//
//  UserRepository.swift
//  Hydro Comrade
//
//  Created by Ismatulla Mansurov on 6/6/21.
//

import Foundation
import Firebase
import CryptoKit
import AuthenticationServices
import SwiftUI



class UserRepository: ObservableObject {
    
    @Published var loggedIn: Bool = false
    @Published var isUploadFinished: Bool = true
    @Published var nonce = ""
    
    @AppStorage ("log_status") var appleLogStatus = false
    @AppStorage ("appleEmail") var appleEmail: String = ""
    @AppStorage ("appleUID") var appleUID: String = ""
    @AppStorage ("appleName") var appleName: String = ""
    @AppStorage ("appleFirestoreExists") var appleFireStoreExists: Bool = false

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
    
    
    
    func signInUser(email: String, password: String, onSucces: @escaping(Bool, String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authData, error) in

                if (error != nil) {
                    print(error!.localizedDescription)
                    onSucces(false, error!.localizedDescription)
                    return
                } else {
                    self.userID = (authData?.user.uid)!
                    print(self.userID)
                    onSucces(true, "")
                    UserDefaults.standard.set(self.userID, forKey: "userID")
                }
        }
    }
    func signUpUser(email: String, password: String, name: String, weight: Double, height: Double, metric: Bool, isCoffeeDrinker: Bool, waterIntake: Double, onSucces: @escaping(Bool, String) -> Void) {
            isUploadFinished = false
            Auth.auth().createUser(withEmail: email, password: password) { (authData, error) in
                if (error != nil) {
                    print(error!.localizedDescription)
                    onSucces(false, error!.localizedDescription)
                    return
                } else {
                    self.userID = (authData?.user.uid)!
                    onSucces(true, "")
                    UserDefaults.standard.set(self.userID, forKey: "userID")

                    self.addUserInformation(name: name, weight: weight, height: height, userID: self.userID, metric: metric, isCoffeeDrinker: isCoffeeDrinker, waterIntake: waterIntake)
                }
            }
    }
    
    func appleAuthenticate(credintial: ASAuthorizationAppleIDCredential, completionHandler: @escaping (Bool) -> Void)  {
        // obtain token

        guard let token = credintial.identityToken else {
            print("error with firebase")
            return
        }
        
        guard let tokenString = String(data: token, encoding: .utf8) else {
            print("error with Token")
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
        
        Auth.auth().signIn(with: firebaseCredential) { (result, err) in
            
            if let error = err {
                print(error.localizedDescription)
                return
            }
            print("Apple sign-in successful")
            
            self.appleEmail = result!.user.email!
            self.appleUID = result!.user.uid
            self.appleLogStatus = true
            
            let appleFirestoreDocumentName = Firestore.firestore().collection("users").document(self.appleUID)
            print("apple UID\(self.appleUID)")
            
            appleFirestoreDocumentName.getDocument { (document, error) in
                if let document = document, document.exists {
                    self.appleFireStoreExists = true
                    self.loggedIn = true
                    self.isUploadFinished = true
                    completionHandler(true)
                    print("document exists \(document.debugDescription)")
                } else {
                    completionHandler(false)
                    self.appleFireStoreExists = false
                }
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
    
    func addUserInformation(name: String, weight: Double, height: Double, userID: String, metric: Bool, isCoffeeDrinker: Bool, waterIntake: Double) {
        print("userID before adding it \(userID)")
        
        Firestore.firestore().collection("users").document(userID).setData([
            "userID": userID,
             "name": name,
             "weight": weight,
             "height": height,
             "metric": metric,
             "waterIntake": waterIntake,
            "isCoffeeDrinker": isCoffeeDrinker
        ]) { onError in
            if onError != nil {
            print(onError.debugDescription)
            } else {
                print("Finished writing to Firebase ")
                self.isUploadFinished = true
            }
        } 
        
        //MARK: USERDEFAULTS: user infromation
        let userInfo: User = User(name: name, height: Int(height), weight: weight, metric: metric, isCoffeeDrinker: isCoffeeDrinker, waterIntake: waterIntake, hydration: [], userUID: userID)
        
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

 func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
    
func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
