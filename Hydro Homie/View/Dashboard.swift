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
    @State var cups: Double = 0
    @State private var cupsLeft: Double = 0
    var cupsArray: Array<Int> = Array()
    @State var percentageWater: Double = 0
    let formatter = NumberFormatter()
    @State private var offset = CGSize.zero
    let timer = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
    @State var waterColor: Color =  Color( red: 1, green: 0.5, blue: 1, opacity: 1)
    @State var isCurrentHydration: Bool = true
    @State var waterViewOpacity: Double = 2
    @State var actionView: Bool = false
    @State private var actionOffset = CGSize.zero
    @Environment(\.colorScheme) var colorScheme
    @State private var popUp: Bool = false
    @State private var isDiuretic: Bool = false
    @State private var previosColor: Color = Color(red: 103 / 255, green: 146 / 255, blue: 103 / 255, opacity: 0.5)
    @State private var formattedFloat : String = ""
    @State private var cupsFormattedFloat: String = ""
    @State private var addCustomAmount: Bool = false
    @State private var waterScaleEffect: CGFloat = 1
    @State private var isInformation: Bool = false
    @State private var isCustomWater: Bool = false
    
    //alchol
    @State private var isAlcoholConsumed: Bool = false
    @State private var percentageOfAlcohol: Double = 0
    @State private var percentageOfEachAlcohol: Double = 0
    @State private var amountOfEachAlcohol: Double = 0
    @State private var isDiureticMode: Bool = false
    @State private var amountOfAccumulatedAlcohol: Double = 0
    
    
    // MARK: User information
    @State var userName: String = ""
    @State var waterIntake: Double = 1
    @State var hydrationDate: String = ""
    @State var calculatedPercentage: Int = 1
    @State var currentHydrationDictionary: [String: Int] = ["": 1]
    @State var volumeMetric: String = "oz"
    @State var isMetric: Bool = false
        
    
    @ObservedObject var alcoholTimer = timerBackground
    
    @ViewBuilder
    var body: some View {
        GeometryReader { reader in
            NavigationView {
                VStack{
                    if isAlcoholConsumed {
                        Text(isDiureticMode ? "Diuretic mode is on" : "Alchol mode is on")
                            .foregroundColor(waterColor)
                            .font(.system(.headline))
                        HStack {
                            AlcoholTimer(isDiureticMode: $isDiureticMode, waterColor: $waterColor)
                            Button(action:{
                                isInformation = true
                            }, label: {
                                Image(systemName: "info.circle")
                            })
                        }
                    }
                    if isCurrentHydration {
                        Text(LocalizedStringKey("\(userName), your daily goal: \( formatter.string(from: NSNumber(value: waterIntake))!) \(volumeMetric)"))
                            .font(.system(size: reader.size.height / 35, weight: .heavy))
                            .foregroundColor(colorScheme == .dark ? Color.gray : waterColor)
                    } else {
                        Text("You have drank \(cupsFormattedFloat) on: \(hydrationDate)")
                            .foregroundColor(colorScheme == .dark ? .gray : waterColor)
                            .font(.system(size: reader.size.height / 40, weight: .heavy))
                    }
                    Spacer(minLength: reader.size.height / 7) //Space between
                    HStack{
                        if actionView{
                            VStack{
                                ActionView()//display the ActionView when the user swipes up
                                    .offset(x: actionOffset.width * 5, y: actionOffset.height * 5)
                                    .environmentObject(userDocument)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { gesture in
                                                self.actionOffset.width = gesture.translation.width / 3
                                                self.actionOffset.height = gesture.translation.height / 3
                                                print(self.$actionOffset)
                                            }
                                            .onEnded { _ in
                                                if actionOffset.height < -30 {
                                                    actionOffset.height = 230
                                                    actionOffset.width = 0
                                                    withAnimation(.easeInOut(duration: 0.75)) {
                                                        waterViewOpacity = 1 // if the user swipes right waterView disappears
                                                        actionView.toggle()
                                                    }
                                                } else {
                                                    actionOffset = CGSize.zero
                                                }
                                                
                                            })
                                    .onReceive(timer, perform: { time in
                                        if actionOffset.height > 1 {
                                            actionOffset.height -= 1
                                        }
                                    })
                            }
                        }
                        else {
                            WaterView(factor: self.$percentageWater, waterColor: $waterColor)
                                .frame(height: reader.size.height / 2)
                                .scaleEffect(waterScaleEffect)
                                .onTapGesture {
                                    if waterScaleEffect == 1.5 {
                                        withAnimation() {
                                            waterScaleEffect = 1
                                        }
                                        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                                        impactHeavy.impactOccurred()
                                    } else {
                                        if isCurrentHydration{
                                            let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                                            impactHeavy.impactOccurred()
                                            isDiuretic = true
                                        }
                                    }
                                }
                                .onLongPressGesture {
                                    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                                    impactHeavy.impactOccurred()
                                    withAnimation {
                                        waterScaleEffect = 1.5
                                    }
                                    
                                }
                                .shadow(color: colorScheme == .dark ? .white : .black, radius: 6)
                                .offset(x: offset.width * 5, y: offset.height * 5)
                                .opacity(waterViewOpacity - Double(abs(offset.width / 1001)))
                                .gesture(
                                    DragGesture()
                                        .onChanged { gesture in
                                            print ( gesture.translation.height / 3)
                                            
                                            //if the user long presses change the water level, else show the context menu
                                            if waterScaleEffect == 1 {
                                                self.offset.width = gesture.translation.width / 3
                                                self.offset.height = gesture.translation.height / 3
                                            } else {
                                                self.cups = Double((-gesture.translation.height / 50))
                                            }
                                        }
                                        .onEnded { _ in
                                            if offset.height < -30 {
                                                offset.height = 230
                                                offset.width = 0
                                                actionOffset.height = 230
                                                actionOffset.width = 0
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
                                            offset.height -= 1
                                        }
                                    }
                                })
                            
                        }
                    }
                    if isCurrentHydration {
                        withAnimation(){
                            Text("cups left today: \(formattedFloat)")
                                .foregroundColor(colorScheme == .dark ? .gray : waterColor)
                                .opacity(waterViewOpacity)
                                .padding()
                        }
                        //MARK: Stepper
                        HStack{
                            CustomStepper(value: $cups, isDiuretic: $isDiuretic, textColor: $waterColor, isCustomWater: $isCustomWater)
                        }
                        .opacity(waterViewOpacity)
                        .opacity(waterScaleEffect == 1.5 ? 0 : 1)
                    }
                    Spacer(minLength: reader.size.height / 9)
                }
                
                //MARK: tool bar
                .toolbar(content: {
                    ToolbarItem(placement: .primaryAction){
                        Button(action: {
                            popUp = true
                        }, label: {
                            Image(systemName: "gear")
                        })
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation(.easeIn(duration: 1.3)){
                                isCurrentHydration = true
                                if percentageOfEachAlcohol < 10 || amountOfAccumulatedAlcohol < 30 {
                                    waterColor = currentWaterColor(colorScheme: colorScheme)
                                }
                                actionView = false
                                hydrationDate = userDocument.getTheLatestDate()
                                currentHydrationDictionary = userDocument.user.hydration.last!
                                waterViewOpacity = 2
                            }
                        }, label: {
                            Image(systemName: "house")
                        })
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Image(systemName: "drop")
                            .scaleEffect(2)
                            .onTapGesture {
                                withAnimation() {
                                    isDiuretic = true
                                }
                            }
                    }
                })
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .accentColor(colorScheme == .dark ? .gray : waterColor)
            
        }.onAppear{
            userDocument.fetchData()
        }
        .onChange(of: userDocument.user.name, perform: { newValue in
            
            self.isMetric = userDocument.user.metric
            self.currentHydrationDictionary = userDocument.user.hydration.last!
            self.cups = Double(userDocument.waterPercentageCalculator(hydrationDictionary: currentHydrationDictionary))
            self.userName = userDocument.getUser().name
            self.waterIntake = userDocument.getUser().waterIntake
            self.hydrationDate = userDocument.getTheLatestDate()
            self.calculatedPercentage = userDocument.waterPercentageCalculator(hydrationDictionary: currentHydrationDictionary)
            self.cupsLeft = waterIntake / Double(cupConverter())
            self.cupsLeft -= self.cups
            _ = ((100 / Int((waterIntake)) / cupConverter())) * calculatedPercentage
            if(userDocument.user.metric == true) {
                volumeMetric = "ml"
            }
        })
        .sheet(isPresented: $popUp, content: {
            PopUp(active: $popUp, cups: $cups, waterColor: $waterColor, isMetric: self.$isMetric, isCustomWater: $isCustomWater, isAlcoholConsumed: self.$isAlcoholConsumed, percentageOfAlcohol: self.$percentageOfAlcohol, percentageOfEachAlcohol: self.$percentageOfEachAlcohol, amountOfEachAlcohol: self.$amountOfEachAlcohol, amountOfAccumulatedAlcohol: self.$amountOfEachAlcohol)
                .environmentObject(user)
                .environmentObject(userDocument)
                .font(.title)
                .clearModalBackground()
                .edgesIgnoringSafeArea(.bottom)
        })
        .sheet(isPresented: $isDiuretic, content: {
            DiureticView(cups: $cups, customDrinkDocument: CustomDrinkViewModel(), waterColor: $waterColor, isCustomWater: $isCustomWater, isMetric: $isMetric, isDiuretic: $isDiuretic, popUp: $popUp, isAlcoholConsumed: $isAlcoholConsumed, amountOfAccumulatedAlcohol: $amountOfAccumulatedAlcohol, percentageOfEachAlcohol: $percentageOfEachAlcohol, amountOfEachAlcohol: $amountOfEachAlcohol)
                .clearModalBackground()
                .edgesIgnoringSafeArea(.bottom)
        })
        .onChange(of: self.currentHydrationDictionary, perform: { newValue in
            for (date,_) in currentHydrationDictionary {
                self.hydrationDate = date
            }
            if (self.currentHydrationDictionary != userDocument.user.hydration.last) {
                waterColor = Color(red: 103 / 255, green: 146 / 255, blue: 103 / 255, opacity: 0.5)
                isCurrentHydration = false
            } else {
                waterColor = currentWaterColor(colorScheme: colorScheme)
                isCurrentHydration = true
            }
            
            self.cups = Double(userDocument.waterPercentageCalculator(hydrationDictionary: currentHydrationDictionary))
            self.calculatedPercentage = userDocument.waterPercentageCalculator(hydrationDictionary: currentHydrationDictionary)
            let percentageWaterMultiply = ((100 / (Int(waterIntake) / cupConverter())) * calculatedPercentage)
            percentageWater = Double(percentageWaterMultiply)
            
        })
        .onChange(of: alcoholTimer.totalAccumulatedTime , perform: { value in
            if value < 1 {
                waterColor = currentWaterColor(colorScheme: colorScheme)
                isAlcoholConsumed = false
            }
        })
        
        .onChange(of: self.cups, perform: { value in
            percentageWater = (100 / ((waterIntake) / Double(cupConverter())) * self.cups)
            hydration.document.uploadCups(cups: Int(cups))
            cupsLeft = (waterIntake / Double(cupConverter())) - cups
            formattedFloat = String(format: "%.1f", cupsLeft)
            cupsFormattedFloat = String(format: "%.1f", cups)
        })
        
        .onChange(of: amountOfAccumulatedAlcohol, perform: { value in
            if self.percentageOfEachAlcohol > 10 || self.amountOfAccumulatedAlcohol > 30 {
                self.waterColor = Color(red: 130 / 255, green: 98 / 255, blue: 222 / 255, opacity: 0.5)
                print("water intake equals: \(waterIntake / Double(cupConverter()))")
                print("alcohol amount equals: \( self.percentageOfEachAlcohol ) %  ")
                
                waterIntake += (waterIntake / 100) * 10
                isDiureticMode  = true
            }
        })
        .alert(isPresented: self.$isInformation, content: {
            Alert(title: Text("Diuretic effect"), message:
                    Text(isDiureticMode ? "Alcohol makes you pee, and dehydrates you if the amount of alcohol exeeds certain amount you start to dehydrate. Don't worry the app takes care of it, just log everything you drink." : "Small amount of alcohol in your drink hydrates your body as much as water does." )
                  , primaryButton: Alert.Button.default(Text("Learn more"), action: {
                if isDiureticMode {
                    UIApplication.shared.open(URL(string: "https://academic.oup.com/alcalc/article/45/4/366/155478?login=true")!)
                } else {
                    UIApplication.shared.open(URL(string: "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5537780/")!)
                }
            }) , secondaryButton: Alert.Button.cancel())
        })
    }
    
    func currentWaterColor(colorScheme: ColorScheme) -> Color {
        var waterColor: Color = Color( red: 0, green: 0, blue: 0, opacity: 0)
        if colorScheme == .dark {
            waterColor = Color( red: 0, green: 0.5, blue: 0.7, opacity: 0.5)
        } else {
            waterColor = Color( red: 0, green: 0.5, blue: 0.8, opacity: 0.5)
        }
        return waterColor
    }
    
    func cupConverter() -> Int {
        var cupConverter: Int = 1
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

struct PopUp: View {
    
    @Binding var active: Bool
    @Binding var cups: Double
    @EnvironmentObject var user: UserRepository
    @EnvironmentObject var userDocument: UserDocument
    @State private var isDiuretic = false
    @State private var isPrecise = false
    @Environment(\.colorScheme) var colorScheme
    @Binding var waterColor: Color
    @Binding var isMetric: Bool
    @Binding var isCustomWater: Bool
    
    @State var isNavigationBarHidden: Bool = true

    //Alcohol
    @Binding var isAlcoholConsumed: Bool
    @Binding var percentageOfAlcohol: Double
    @Binding var percentageOfEachAlcohol: Double
    @Binding var amountOfEachAlcohol: Double
    @Binding var amountOfAccumulatedAlcohol: Double
    
    
    var body: some View {
        
        //                HStack{
        //                    Spacer()
        //                    Button(action: {
        //                        active = false
        //                    }, label: {
        //                        Text("Done")
        //                    }).scaleEffect(0.75)
        //                }
        ZStack {
            NavigationView {
                VStack {
                    HStack {
                        Spacer()
                        Button("Done", action: {
                            active = false
                        })
                        .padding()
                    }
                    NavigationLink(
                        
                        destination: ActionView().environmentObject(userDocument),
                        label: {
                            Text("Action Control")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        })
                    
                    HStack {
                        Text("Precise Control")
                        Image(systemName: "figure.walk")
                            .padding()
                    }
                    .onTapGesture {
                        isPrecise.toggle()
                    }
                    
                    Text("Log diuretic")
                        .onTapGesture {
                            withAnimation() {
                                isDiuretic.toggle()
                            }
                        }
                    if isPrecise {
                        PreciseControl()
                    }
                    
                    Text("Sign out")
                        .onTapGesture {
                            user.signOut()
                        }
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width - 50)
                        .cornerRadius(23)
                    
                    Spacer()
                }
                .navigationBarTitle("Action Control")
                .navigationBarHidden(self.isNavigationBarHidden)
            }
        }
        .onAppear {
            isNavigationBarHidden = true
        }
        .sheet(isPresented: $isDiuretic, content: {
            DiureticView(cups: $cups, customDrinkDocument: CustomDrinkViewModel(), waterColor: $waterColor, isCustomWater: $isCustomWater, isMetric: $isMetric, isDiuretic: $isDiuretic, popUp: $active, isAlcoholConsumed: $isAlcoholConsumed, amountOfAccumulatedAlcohol: $amountOfAccumulatedAlcohol, percentageOfEachAlcohol: $percentageOfEachAlcohol, amountOfEachAlcohol: $amountOfEachAlcohol)
                .clearModalBackground()
                .edgesIgnoringSafeArea(.bottom)
        })
        
    }
}



