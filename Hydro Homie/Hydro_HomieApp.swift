    //
    //  Hydro_HomieApp.swift
    //  Hydro Homie
    //
    //  Created by Ismatulla Mansurov on 4/26/21.
    //
    
    import SwiftUI
    import Firebase
    import UIKit
    import CoreLocation
    
        @main
    struct Hydro_HomieApp: App {
         init() {
                setupAuthentication()
        }
        let context = PersistanceController.shared

        var body: some Scene {
            WindowGroup {
                ContentView()
                    .environmentObject(UserRepository())
                
            }
        }
    }

    extension Hydro_HomieApp {
        private func setupAuthentication() {
            FirebaseApp.configure()
        }
    }

