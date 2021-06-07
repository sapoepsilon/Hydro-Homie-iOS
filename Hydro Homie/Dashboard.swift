//
//  Dashboard.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 4/27/21.
//

import SwiftUI
import Firebase

var enough: Bool = false
var newDate: Bool = false
let db = Firestore.firestore()
let cupsDate = Date()
let format = DateFormatter()
var arrayOfCups: [(Int, String)] = []

struct Dashboard: View {
    
    @State var cups = 0
    var cupsArray: Array<Int> = Array()
    var body: some View {
        
        let userID = Auth.auth().currentUser?.uid
        let docRef = db.collection("users").document(userID!)
        VStack{
            if(enough == false){
                Text("You have drank \(cups) today")
                    .foregroundColor(.black)
                    .font(.title2)
            } else {
                Text("You have drank \(cups) cups of water today. Congragulations, you have drank enough water today")
                    .foregroundColor(.green)
                    .font(.title2)
                
            }
            
            Spacer().frame(height: 250)
            Button(action: {
                cups += 1
                if(cups >= 8) {
                    enough = true
                    format.dateFormat = "yyyy-MM-dd"
                    let today = format.string(from: cupsDate)
                    
                    let docData: [String: Any] = [
                        "hydration": [cups, today],
                    ]


                    
                    do {
                        try docRef.setData([   "hydration": FieldValue.arrayUnion([
                                docData
                            ])
                        ], merge: true
                        )} catch let error {
                        print("Error writing city to Firestore: \(error)")
                    }
                    
        
                    
                }
                   
            }, label: {
            
                WaterView(percent: (10) * cups)
                
            })
            
            
            NavigationView{
                NavigationLink(destination: ContentView()){
                    Text("Sign out")
                        
                        .onTapGesture {
                            try! Auth.auth().signOut()
                        }
                    
                }
                .foregroundColor(.black)
                .padding(.vertical)
                .frame(width: UIScreen.main.bounds.width - 50)
            }.background(Color.black)
            .cornerRadius(23)
            .padding(.top, 23)
            
        }.onAppear(
        )
        
    }
    func fetchData() {
        
        let userID = Auth.auth().currentUser?.uid
        let docRef = db.collection("users").document(userID!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
        
    }
}


