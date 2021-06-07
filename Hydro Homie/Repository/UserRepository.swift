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
    
    func checkUser() {
        Auth.auth().addStateDidChangeListener { auth, user in
          if let user = user {
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
                    self.loggedIn = true
                }
        }
    }
    static func signUpUser(email: String, password: String, username: String, onSucces: @escaping() -> Void, onError: @escaping (_ errorMessage : String) -> Void ) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authData, error) in
            if (error != nil) {
                print(error!.localizedDescription)
                onError(error!.localizedDescription)
                return
            }
            //Sign Up Code
            
        }
    }
    
    
}
