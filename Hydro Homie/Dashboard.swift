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
    @State private var offset = CGSize.zero
    let timer = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()

    
    // MARK: User information
    @State var userName: String = ""
    @State var waterIntake: Double = 0
    @State var hydrationDate: String = ""
    @State var calculatedPercentage: Int = 0
    @State var currentHydrationDictionary: [String: Int] = ["": 0]
    
    var body: some View {
        
        GeometryReader { reader in
            VStack{
                Text("\(userName), your daily goal: \( formatter.string(from: NSNumber(value: waterIntake))!) oz")
                    .font(.system(size: reader.size.height / 35, weight: .heavy))
                Text("You have drank \(cups) cups today: \(hydrationDate)")
                    .foregroundColor(.black)
                    .font(.title3)
                Spacer(minLength: reader.size.height / 5)
                
                HStack{
                    WaterView(factor: self.$percentageWater)
                        .frame(height: reader.size.height / 2)
                        .onTapGesture {
                            cups += 1
                            percentageWater += (100 / (waterIntake / 8))
                            hydration.document.uploadCups(cups: cups)
                        }
                        .offset(x: offset.width * 5, y: 0)
                        .opacity(2 - Double(abs(offset.width / 50)))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    withAnimation(.linear(duration: 0.2)) {
                                    self.offset.width = gesture.translation.animatableData.first
                                    }
//                                    self.offset.height = self.offset.height
                               
//                                    print("offset width while moving : \(offset.width)")
//                                    print("offset height while moving : \(offset.height)")
                                }

                                .onEnded { _ in
                                    if self.offset.width > 50 {
//                                        print(offset)
                                        self.currentHydrationDictionary = userDocument.previousDate(hydrationArray: self.currentHydrationDictionary)
                                        print(self.currentHydrationDictionary)

                                            offset.width = -89.5

                                    } else if self.offset.width < -50 {
                                        self.currentHydrationDictionary = userDocument.nextDate(hydrationArray: self.currentHydrationDictionary)
                                        print(self.currentHydrationDictionary)

                                            offset.width = 89.5
                                    } else {
                                        self.offset = .zero
                                    }
                                }
                        )
                        .onReceive(timer, perform: {time in
                        if offset.width < -1 {
                            offset.width += 1
                        } else if offset.width > 1 {
                            offset.width -= 1
                        }
                        
                    })
//                        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
//                                    .onEnded({ value in
//                                        if value.translation.width < 0 {
//                                            user.previousDates()
//                                        }
//                                    }))
//                    Text("Minus cup")
//                        .onTapGesture {
//                            cups -= 1
//                        }
                }
                
                Text("cups left today: \(formatter.string(from: NSNumber(value: (Int(waterIntake) / 8) - self.cups))!) ")
                Spacer(minLength: reader.size.height / 8)
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
        .onChange(of: userDocument.user.hydration, perform: { newValue in
            
            self.currentHydrationDictionary = userDocument.user.hydration.last!
            self.cups = userDocument.waterPercentageCalculator()
            self.userName = userDocument.getUser().name
            self.waterIntake = userDocument.getUser().waterIntake
            self.hydrationDate = userDocument.getTheLatestDate()
            self.calculatedPercentage = userDocument.waterPercentageCalculator()
            let percentageWaterMultiply = ((100 / (Int(waterIntake) / 8)) * calculatedPercentage)
            percentageWater = Double(percentageWaterMultiply)
            print("water percentage calculator \(percentageWater)")
            print("water intake \(waterIntake)")
            print("percentage water amount \(percentageWaterMultiply)")
            
        })
        .onChange(of: self.currentHydrationDictionary, perform: { newValue in
            print("current date after changing it \(self.currentHydrationDictionary.description)")

            for (date,_) in currentHydrationDictionary {
                self.hydrationDate = date
                print("hydration date after changing it \(self.hydrationDate)")
            }
            
        })
    }
    

}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard(userDocument: UserDocument())
    }
}


