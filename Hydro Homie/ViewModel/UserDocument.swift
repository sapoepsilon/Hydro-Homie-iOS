//
//  UserDocument.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/9/21.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserDocument: ObservableObject {
    
    let db = Firestore.firestore()
    
    @Published var user: User = User(name: "", height: 0, weight: 0, metric: false, waterIntake: 0)
    
    func fetchData() {
        let currentUserID = Auth.auth().currentUser?.uid

        db.collection("users").document(currentUserID!).addSnapshotListener { (querySnapshot, error) in
            guard let document = querySnapshot?.data()
            else {
                print("No documents")
                return
            }
            let name = document["name"] as? String ?? ""
            let height = document["height"] as? Int ?? 0
            let weight = document["Weight"] as? Double ?? 0
            let metric = document["metric"] as? Bool ?? false
            let waterIntake = document["waterIntake"] as? Double ?? 0
    
            self.user = User(name: name , height: height, weight: weight, metric: metric, waterIntake: waterIntake)
            print(self.user.metric)
    }

            
        }
    }
        
    
    

