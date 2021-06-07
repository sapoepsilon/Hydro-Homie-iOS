//
//  SessionAuth.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/6/21.
//

import Foundation
import FirebaseAuth

class SessionAuth: ObservableObject {
    
    @Published var isLoggedIn = true
    var handle : AuthStateDidChangeListenerHandle?
    
    func listenAuthentificationState() {
        
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if let user = user {
                //You are log in
                // Your login process code
                self.isLoggedIn = true
            }
            else {
                //You are not
                self.isLoggedIn = false
            }
        }
        })
}
