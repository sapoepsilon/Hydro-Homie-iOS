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
    @State private var cupsLeft: Int = 0
    var cupsArray: Array<Int> = Array()
    @State var percentageWater: Double = 0
    let formatter = NumberFormatter()
    @State private var offset = CGSize.zero
    let timer = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
    @State var waterColor: Color =  Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5)
    @State var isCurrentHydration: Bool = true
    @State var waterViewOpacity: Double = 2
    @State var actionView: Bool = false
    
    // MARK: User information
    @State var userName: String = ""
    @State var waterIntake: Double = 1
    @State var hydrationDate: String = ""
    @State var calculatedPercentage: Int = 1
    @State var currentHydrationDictionary: [String: Int] = ["": 1]
    @State var volumeMetric: String = "oz"
    @State var isMetric: Bool = false
    
    var body: some View {
        
        GeometryReader { reader in
            
            VStack{
                Text("\(userName), your daily goal: \( formatter.string(from: NSNumber(value: waterIntake))!) \(volumeMetric)")
                    .font(.system(size: reader.size.height / 35, weight: .heavy))
                Text("You have drank \(cups) \(cup()) today: \(hydrationDate)")
                    .foregroundColor(.black)
                    .font(.title3)
        
                Spacer(minLength: reader.size.height / 9)
                
                HStack{
                    if actionView{
                        VStack{
                            ActionView() //display the ActionView when the user swipes right
                                .onTapGesture {
                                    withAnimation(.easeOut(duration: 2.2)) {
                                        waterViewOpacity = 2
                                    }
                                    actionView.toggle()

                                }
                        }
                    } else {
                        WaterView(factor: self.$percentageWater, waterColor: $waterColor)
                            .frame(height: reader.size.height / 2)
                            .onTapGesture {
                                if isCurrentHydration {
                                    cups += 1
                                    percentageWater += (100 / (waterIntake / Double(cupConverter())))
                                    hydration.document.uploadCups(cups: cups)
                                    cupsLeft -= 1
                                }
                            }
                            .offset(x: offset.width * 5, y: offset.height * 5)
                            .opacity(waterViewOpacity - Double(abs(offset.width / 50)))
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        print ( gesture.translation.height / 3)
                                        self.offset.width = gesture.translation.width / 3
                                        self.offset.height = gesture.translation.height / 3
                                        
                                    }
                                    .onEnded { _ in
                                        if offset.height < -80 {
                                            offset.height = 130
                                            offset.width = 0
                                            withAnimation(.easeInOut(duration: 0.75)) {
                                                waterViewOpacity = 0 // if the user swipes right waterView disappears
                                                actionView = true
                                            }

                                        } else if self.offset.width > 50 {
                                            self.currentHydrationDictionary = userDocument.previousDate(hydrationArray: self.currentHydrationDictionary)
                                            offset.width = -89.5
                                            offset.height = 0
                                        } else if self.offset.width < -50 {
                                            self.currentHydrationDictionary = userDocument.nextDate(hydrationArray: self.currentHydrationDictionary)
                                            offset.width = 89.5
                                            offset.height = 0
                                        }
                                    }
                            )
                            .onReceive(timer, perform: {time in
                                if offset.width < -1 {
                                    offset.width += 1
                                } else if offset.width > 1 {
                                    offset.width -= 1
                                } else if offset.height > 1 {
                                    if !actionView {
                                        offset.height -= 0.5
                                    }
                                }
                            })
                    }
                }
                Text("cups left today: \(cupsLeft) ")
                    .opacity(waterViewOpacity)
                HStack{
                    Stepper(onIncrement: {
                        cups += 1
                        percentageWater += (100 / (waterIntake / Double(cupConverter())))
                        cupsLeft -= 1
                    }, onDecrement: {
                        cups -= 1
                        percentageWater -= (100 / (waterIntake / Double(cupConverter())))
                        cupsLeft += 1
                    }, label: {Text("Cups")}).labelsHidden()
                }.opacity(waterViewOpacity)
                Spacer(minLength: reader.size.height / 9)
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
//            print(context)
        }
        .onDisappear{
            UserDefaults.standard.setValue(cups, forKey: "cups")
        }
        .onChange(of: userDocument.user.name, perform: { newValue in
            self.isMetric = userDocument.user.metric
            self.currentHydrationDictionary = userDocument.user.hydration.last!
            self.cups = userDocument.waterPercentageCalculator(hydrationDictionary: currentHydrationDictionary)
            self.userName = userDocument.getUser().name
            self.waterIntake = userDocument.getUser().waterIntake
            self.hydrationDate = userDocument.getTheLatestDate()
            self.calculatedPercentage = userDocument.waterPercentageCalculator(hydrationDictionary: currentHydrationDictionary)
            self.cupsLeft = Int(waterIntake) / (cupConverter() - self.cups)
            self.cupsLeft -= self.cups
            _ = ((100 / (Int(waterIntake) / cupConverter())) * calculatedPercentage)
            if(userDocument.user.metric == true) {
                volumeMetric = "ml"
            }
            
        })
        .onChange(of: self.currentHydrationDictionary, perform: { newValue in
            for (date,_) in currentHydrationDictionary {
                self.hydrationDate = date
            }
            if (self.currentHydrationDictionary != userDocument.user.hydration.last) {
                waterColor = Color(red: 103 / 255, green: 146 / 255, blue: 103 / 255, opacity: 0.5)
            } else {
                waterColor = Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5)
            }
            if currentHydrationDictionary != userDocument.user.hydration.last {
                isCurrentHydration = false
            } else {
                isCurrentHydration = true
            }
            
            self.cups = userDocument.waterPercentageCalculator(hydrationDictionary: currentHydrationDictionary)
            self.calculatedPercentage = userDocument.waterPercentageCalculator(hydrationDictionary: currentHydrationDictionary)
            let percentageWaterMultiply = ((100 / (Int(waterIntake) / cupConverter())) * calculatedPercentage)
            percentageWater = Double(percentageWaterMultiply)
            
        })
        
    }
    
    func cupConverter() -> Int {
        var cupConverter:Int = 1
        if isMetric {
            cupConverter = 237
        } else {
            cupConverter = 8
        }
        return cupConverter
    }
    
    func cup() -> String {
        if self.cups == 1 || self.cups == 0 {
            return "cup"
        } else {
            return "cups"
        }
    }
    
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        Dashboard(userDocument: UserDocument(), context: <#Environment<DataStore>#>)
//    }
//}


