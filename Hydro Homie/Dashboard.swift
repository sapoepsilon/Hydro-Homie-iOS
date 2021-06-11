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
    @EnvironmentObject var user: UserRepository
    @ObservedObject var userDocument: UserDocument
    @State var cups: Int = 0
    @State private var cupsLeft: Double = 0
    var cupsArray: Array<Int> = Array()
    @State var percentageWater: Double = 0
    let formatter = NumberFormatter()
    var body: some View {
        
            GeometryReader { reader in
                VStack{
                    Text("Hello \(userDocument.user.name) you need to drink daily \( formatter.string(from: NSNumber(value: userDocument.user.waterIntake))!) ounces")
                    Text("You have drank \(cups) cups today")
                        .foregroundColor(.black)
                        .font(.title2)
                    
                    WaterView(factor: self.$percentageWater)
                        .frame(height: reader.size.height / 2)
                        .onTapGesture {
                            cups += 1
                            percentageWater = percentageWater + Double(100 / (userDocument.user.waterIntake / 8))
                            print(percentageWater)
                            if(cups >= 8) {
                                hydration.updateHydration(cups: cups)
                            }
                        }
                    
                    Text("cups left today: \(formatter.string(from: NSNumber(value: (userDocument.user.waterIntake / 8) - Double(cups)))!) ")
                    Spacer(minLength: reader.size.height / 3)
                        Text("Sign out")
                                .onTapGesture {
                                    user.signOut()
                                }
                        .foregroundColor(.black)
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width - 50)
                        .cornerRadius(23)
                }
            }.onAppear{
                userDocument.fetchData()
            }
    }
    
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard(userDocument: UserDocument())
    }
}


