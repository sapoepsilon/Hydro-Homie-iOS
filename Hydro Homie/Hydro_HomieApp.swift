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
                setupAuthentication()
        }
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
