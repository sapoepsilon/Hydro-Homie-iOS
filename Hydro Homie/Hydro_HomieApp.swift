    //
//  Hydro_HomieApp.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 4/26/21.
//

import SwiftUI
import Firebase

@main
struct Hydro_HomieApp: App {
    
    @UIApplicationDelegateAdaptor(Delegate.self) var delegate
    init() {
      FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        }
    }
}
    
    class Delegate : NSObject, UIApplicationDelegate{
        
        func application (_ application: UIApplication, didFinishLaunchingwithOptions lunchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            
            FirebaseApp.configure()
            return true
        }
    }

    extension UIApplication {
        func addTapGestureRecognizer() {
            guard let window = windows.first else { return }
            let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
            tapGesture.requiresExclusiveTouchType = false
            tapGesture.cancelsTouchesInView = false
            tapGesture.delegate = self
            window.addGestureRecognizer(tapGesture)
        }
    }

    extension UIApplication: UIGestureRecognizerDelegate {
        public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return false // set to `false` if you don't want to detect tap during other gestures
        }
    }
