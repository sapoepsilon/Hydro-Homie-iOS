//
//  GoogleLogin.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/8/21.
//

import SwiftUI
import GoogleSignIn
import FirebaseApp

class GoogleDelegate: NSObject, GIDSignInDelegate, ObservableObject {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        
        // If the previous `error` is null, then the sign-in was succesful
        print("Successful sign-in!")
        signedIn = true
    }
    
    let googleDelegate = GoogleDelegate()
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func application(_application: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        return true
    }
    

    @Published var signedIn: Bool = false
    
}
