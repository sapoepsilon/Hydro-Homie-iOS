//
//  Dashboard.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 4/27/21.
//

import SwiftUI
import Firebase



struct Dashboard: View {
    
    @EnvironmentObject var hydration: HydrationDocument
    @State var cups = 0
    var cupsArray: Array<Int> = Array()
    var body: some View {
        
        VStack{

                Text("You have drank \(cups) today")
                    .foregroundColor(.black)
                    .font(.title2)
            }
            
            Spacer().frame(height: 250)
        
            Button(action: {
                cups += 1
                if(cups >= 8) {
                    hydration.updateHydration(cups: cups)
                }
                   
            }, label: {
                WaterView(percent: 10 *  self.cups)
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
            
        }
        
    }



