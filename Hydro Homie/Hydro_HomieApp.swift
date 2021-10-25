    //
    //  Hydro_HomieApp.swift
    //  Hydro Homie
    //
    //  Created by Ismatulla Mansurov on 4/26/21.
    //
    
    import SwiftUI
    import Firebase
    import UIKit

       @main
    struct Hydro_HomieApp: App {
        init() {
                DisplayLink.sharedInstance.createDisplayLink()
            }
        @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        var body: some Scene {
            WindowGroup {
                ContentView(    )
                    .environmentObject(UserRepository())
            }
        }
        
        class AppDelegate: NSObject, UIApplicationDelegate {

            func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
                FirebaseApp.configure()
                return true
            }
        }
    }

extension Hydro_HomieApp {
  private func setupAuthentication() {
    FirebaseApp.configure()
//    GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
  }
}

