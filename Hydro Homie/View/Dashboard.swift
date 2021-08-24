//
//  Dashboard.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 4/27/21.
//

import SwiftUI
import Firebase
import UserNotifications




struct Dashboard: View {
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    @StateObject var customDrinkDocument: CustomDrinkViewModel
    
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
    
    // quick drink addition
    @State private var quickDrinkOpacity: Double = 1
    @State private var isQuickDrink: Bool = false
    @State private var waterBackgroundColor: Color = Color.black
    
    //alchol
    @State private var isAlcoholConsumed: Bool = false
    @State private var percentageOfAlcohol: Double = 0
    @State private var percentageOfEachAlcohol: Double = 0
    @State private var amountOfEachAlcohol: Double = 0
    @State private var isDiureticMode: Bool = false
    @State private var amountOfAccumulatedAlcohol: Double = 0
    
    //Notification Trigger
    @State private var notificationInterval: Double  = 20
    @State private var notificationCountDown: Bool = false
    @State private var previousCup: Double = 0
    
    //Background colors
    @Binding  var backgroundColorTop: Color
    @Binding  var backgroundColorBottom: Color
    @State private var backgroundOpacity: Double = 0.001
    @State private var isFirstMenu = false
    
    
    // MARK: User information
    @State var userName: String = ""
    @State var waterIntake: Double = 1
    @State var hydrationDate: String = ""
    @State var calculatedPercentage: Double = 1
    @State var currentHydrationDictionary: [String: Double] = ["": 1]
    @State var volumeMetric: String = "oz"
    @State var isMetric: Bool = false
    
    @ObservedObject var notificationTimerDocument = notificationTimeInterval
    @ObservedObject var alcoholTimer = timerBackground
    
    var body: some View {
        
        GeometryReader { reader in
            NavigationView {
                ZStack{
                    LinearGradient(gradient: Gradient(colors: [backgroundColorTop , backgroundColorBottom]), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.vertical)
                    VStack {
                        if isAlcoholConsumed {
                            alcoholConsumed()
                        }
                        hydrationInfromation(reader: reader)
                        HStack{
                            if actionView {
                                VStack{
                                    stats()
                                }
                            }
                            else {
                                waterDrop(reader: reader)
                            }
                        }
                        notificationTimer()
                            .opacity(actionView ? 0 : 1)
                        
                        if isCurrentHydration {
                            withAnimation(){
                                Text("cups left today: \(formattedFloat)")
                                    .foregroundColor(colorScheme == .dark ? .gray : waterColor)
                                    .opacity(waterViewOpacity)
                                    .padding()
                            }
                            //MARK: Stepper
                           stepper()
                            .opacity(waterViewOpacity)
                            .opacity(waterScaleEffect == 1.5 ? 0 : 1)
                        }
                        Spacer(minLength: reader.size.height / 9)
                    }
                }
                
                //            MARK: tool bar
                
                .toolbar(content: {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            popUp = true
                        }, label: {
                            Image(systemName: "gear")
                        })
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            let cupsDate = Date()
                            format.dateFormat = "yyyy-MM-dd"
                            let today = format.string(from: cupsDate)
                            withAnimation(.easeIn(duration: 1.3)){
                                isCurrentHydration = true
                                waterColor = currentWaterColor(colorScheme: colorScheme)
                                actionView = false
                                hydrationDate = userDocument.getTheLatestDate()
                                currentHydrationDictionary = userDocument.user.hydration.last ?? [today:0]
                                waterViewOpacity = 2
                            }
                        }, label: {
                            Image(systemName: "house")
                        })
                    }
                })
            }
            .toolbar(content: {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    drop()
                    Spacer()
                    Image(systemName: "plus")
                        .opacity(customDrinkDocument.drinkOpacity)
                        .scaleEffect(2)
                        .foregroundColor(waterColor)
                        .onTapGesture {
                            plus()
                        }
                        .padding()
                }
            })
            .navigationViewStyle(StackNavigationViewStyle())
            
            
            Background(percentageOfEachAlcohol: $percentageOfEachAlcohol, amountOfAccumulatedAlcohol: $amountOfEachAlcohol, isAlcoholConsumed: $isAlcoholConsumed, cups: $cups, backgroundOpacity: $backgroundOpacity, isQuickDrink: $isQuickDrink,   isFirstMenu: $isFirstMenu )
                .environmentObject(customDrinkDocument)
                .opacity(isQuickDrink ? 1 : 0)
        }
        .onAppear{
            userDocument.fetchData()
            customDrinkDocument.getDrinkOpacity()
            if colorScheme == .light {
                let toolBarBackground = UIColor(self.backgroundColorBottom)
                UIToolbar.appearance().barTintColor = toolBarBackground
            } else {
                UIToolbar.appearance().barTintColor = UIColor(red: 38/255, green: 40/255, blue: 42/255, alpha: 46/100)
            }
            hydration.requestNotifiactionPermission()
            waterBackgroundColor = backgroundColorTop

        }
        
        .onChange(of: userDocument.user.name, perform: { newValue in
            self.isMetric = userDocument.user.metric
            let cupsDate = Date()
            format.dateFormat = "yyyy-MM-dd"
            let today = format.string(from: cupsDate)
            self.currentHydrationDictionary = userDocument.user.hydration.last ?? [today : 0]
//            self.cups = Double(userDocument.waterPercentageCalculator(hydrationDictionary: currentHydrationDictionary))
            self.userName = userDocument.getUser().name
            self.waterIntake = userDocument.getUser().waterIntake
            self.hydrationDate = userDocument.getTheLatestDate()
//            self.calculatedPercentage = userDocument.waterPercentageCalculator(hydrationDictionary: currentHydrationDictionary)
            self.cupsLeft = waterIntake / Double(cupConverter())
            self.cupsLeft -= self.cups
       
            if(userDocument.user.metric == true) {
                volumeMetric = "ml"
            }
        })
        
        .sheet(isPresented: $popUp, content: {
            PopUp(active: $popUp, cups: $cups, customDrinkDocument: customDrinkDocument, waterColor: $waterColor, isMetric: $isMetric, isCustomWater: $isCustomWater, backgroundColorTop: $backgroundColorTop, backgroundColorBottom: $backgroundColorBottom, isAlcoholConsumed: $isAlcoholConsumed, percentageOfAlcohol: $percentageOfAlcohol, percentageOfEachAlcohol: $percentageOfEachAlcohol, amountOfEachAlcohol: $amountOfEachAlcohol, amountOfAccumulatedAlcohol: $amountOfAccumulatedAlcohol)
                .environmentObject(customDrinkDocument)
                .environmentObject(user)
                .environmentObject(userDocument)
                .clearModalBackground()
                .edgesIgnoringSafeArea(.bottom)
        })
        
        .halfASheet(isPresented: $isDiuretic, content: {
            DiureticView(cups: $cups, waterColor: $waterColor, isCustomWater: $isCustomWater, isMetric: $isMetric, isDiuretic: $isDiuretic, popUp: $popUp, isAlcoholConsumed: $isAlcoholConsumed, amountOfAccumulatedAlcohol: $amountOfAccumulatedAlcohol, percentageOfEachAlcohol: $percentageOfEachAlcohol, amountOfEachAlcohol: $amountOfEachAlcohol)
                .environmentObject(customDrinkDocument)
                .clearModalBackground()
                .edgesIgnoringSafeArea(.bottom)
        })
        .onChange(of: isDiureticMode, perform: { value in
            waterColor = currentWaterColor(colorScheme: colorScheme)
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
            format.dateFormat = "yyyy-MM-dd"
            let cupsDate = Date()
            let today = format.string(from: cupsDate)
            print("Current hydration document \(currentHydrationDictionary.debugDescription)")
            self.cups = hydration.getCups(hydrationDictionary: currentHydrationDictionary, lastHydration: userDocument.user.hydration.last ?? [today : 0])
//            self.calculatedPercentage = userDocument.waterPercentageCalculator(hydrationDictionary: currentHydrationDictionary)
//            let percentageWaterMultiply = ((100 / (Int(waterIntake) / cupConverter())) * calculatedPercentage)
//            percentageWater = Double(percentageWaterMultiply)
        })
        
        .onChange(of: notificationInterval, perform: { value in
            print("notification Interval changed: \(notificationInterval)")
        })
        .onChange(of: alcoholTimer.totalAccumulatedTime , perform: { value in
            if value < 1 || alcoholTimer.isStopped {
                waterColor = currentWaterColor(colorScheme: colorScheme)
                isDiureticMode = false
                isAlcoholConsumed = false
            }
        })
        .onChange(of: notificationTimerDocument.totalAccumulatedTime , perform: { value in
            if value < 1 || notificationTimerDocument.isStopped {
                notificationCountDown = false
            }
        })
        .onChange(of: self.cups, perform: { value in
            
            print("cups have changed \(cups)")
            let lastCup = UserDefaults.standard.double(forKey: "cups")
            previousCup = cups - lastCup
            percentageWater = (100 / ((waterIntake) / Double(cupConverter())) * self.cups)
            hydration.document.uploadCups(cups: cups)
            cupsLeft = (waterIntake / Double(cupConverter())) - cups
            formattedFloat = String(format: "%.1f", cupsLeft)
            cupsFormattedFloat = String(format: "%.1f", cups)
            cupLocal()
        })
        
        .onChange(of: amountOfAccumulatedAlcohol, perform: { value in
            if self.percentageOfEachAlcohol > 10 || self.amountOfAccumulatedAlcohol > 30 {
                withAnimation {
                    isDiureticMode  = true
                    waterColor = currentWaterColor(colorScheme: colorScheme)
                    waterIntake += (waterIntake / 100) * 10
                }
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
    //MARK: Stepper function
    func stepper() -> some View {
       return HStack{
            CustomStepper(value: $cups, isDiuretic: $isDiuretic, textColor: $waterColor, isCustomWater: $isCustomWater)
        }
    }
    func calculateNotificationInterval(waterIntake: Double, awakeness: Double) -> Double {
       
        let minutes: Double = 60
        let seconds: Double = 60
        var notificationInterval = ((awakeness / waterIntake) * minutes) * seconds
        print("notification interval \(notificationInterval) is divided by previous cup \(previousCup)")
        notificationInterval *= previousCup
        print("notification interval: \(notificationInterval / 60) in minutes")
        return notificationInterval
    }
    
    func currentWaterColor(colorScheme: ColorScheme) -> Color {
        var waterColor: Color = Color( red: 0, green: 0, blue: 0, opacity: 0)
        
        if !isDiureticMode {
            if colorScheme == .light {
                waterColor = Color( red: 0, green: 0.5, blue: 0.8, opacity: 1)
            } else {
                waterColor = Color( red: 0, green: 0.5, blue: 0.7, opacity: 1)
            }
        } else {
            waterColor = Color(red: 130 / 255, green: 98 / 255, blue: 222 / 255, opacity: 0.5)
        }
        return waterColor
    }
    
    func plus(){
        withAnimation() {
            isQuickDrink.toggle()
            if isQuickDrink {
                backgroundOpacity = 0.6
                isFirstMenu = true
            } else {
                backgroundOpacity = 0.00
            }
        }
    }
    //MARK: Quick Menu functions
    
    func drop() -> some View {
        return
            Image(systemName: "drop")
            .scaleEffect(2)
            .onTapGesture {
                withAnimation() {
                    isDiuretic = true
                }
            }
    }
    
    //MARK: Notifcation Timer View
    func notificationTimer() -> some View {
        return   HStack {
            if notificationCountDown {
                Text("Next Drink in: ")
                    .font(.title)
                    .foregroundColor(waterColor)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                NotificationTimer(timeInterval: $notificationInterval)
            } else {
                EmptyView()
            }
        }.opacity(isCurrentHydration ? 1 : 0)
    }
    func customWaters() -> some View {
        ForEach(customDrinkDocument.customDrinks, id: \.self) { drink in
            if drink.isCustomWater {
                
                HStack() {
                    Text(drink.name)
                        .foregroundColor(colorScheme == .light ? .black : .white)
                        .padding()
                        .onTapGesture {
                            cups += drink.amount
                            isDiuretic = false
                            popUp = false // close the .sheet and go back to the dashboard
                        }
                    let formattedFloat = String(format: "%.1f", drink.amount)
                    Text(formattedFloat)
                }
            }
        }
    }
    
    //MARK: function to save and retrieve cups in UserDefaults
    
    func cupLocal() {
        if isCurrentHydration {
            let waterIntakeConverted = waterIntake / Double(cupConverter())
            let cuplocal = UserDefaults.standard.double(forKey: "cups")
            if cups > cuplocal && cups != 0 {
                let updateTheTimerView = cups - cuplocal
                print("update the timer view \(updateTheTimerView)")
                
                if updateTheTimerView == 1 {
                    let number = Int.random(in: 0..<10)
                    print("random number \(number)_")
                    notificationInterval -= Double(number)
                }
                notificationInterval = calculateNotificationInterval(waterIntake: waterIntakeConverted, awakeness: 16)
                hydration.addNotification(timeInterval: notificationInterval)
                    notificationCountDown = true
            }
            UserDefaults.standard.set(cups, forKey: "cups")
        }
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
    
    func waterDrop(reader: GeometryProxy) -> some View {
        return
            WaterView(factor: self.$percentageWater, waterColor: $waterColor, backgroundColor: $waterBackgroundColor)
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
//            .onLongPressGesture {
//                let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
//                impactHeavy.impactOccurred()
//                withAnimation {
//                    if isCurrentHydration {
//                        waterScaleEffect = 1.5
//                    }
//                }
//                
//            }
            .shadow(color: colorScheme == .dark ? .white : .black, radius: 6)
            .offset(x: offset.width * 5, y: offset.height * 5)
            .opacity(waterViewOpacity - Double(abs(offset.width / 1001)))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        
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
            
            .onReceive(timer, perform: { time in
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
    
    //MARK: Display stats
    func stats() -> some View {
        return
            ActionView()//display the ActionView when the user swipes up
            .offset(x: actionOffset.width * 5, y: actionOffset.height * 5)
            .environmentObject(userDocument)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        self.actionOffset.width = gesture.translation.width / 3
                        self.actionOffset.height = gesture.translation.height / 3
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
    //MARK: hydration information
    func hydrationInfromation(reader: GeometryProxy) -> some View {
        return VStack {
            if isCurrentHydration {
                Text(LocalizedStringKey("\(userName), your daily goal: \( formatter.string(from: NSNumber(value: waterIntake))!) \(volumeMetric)"))
                    .font(.system(size: reader.size.height / 35, weight: .heavy))
                    .foregroundColor(colorScheme == .dark ? Color.gray : waterColor)
            }
            else {
                Text("You have drank \(cupsFormattedFloat) on: \(hydrationDate)")
                    .foregroundColor(colorScheme == .dark ? .gray : waterColor)
                    .font(.system(size: reader.size.height / 40, weight: .heavy))
                Spacer().frame(height: UIScreen.main.bounds.size.height / 20)
            }
            if UIDevice.current.userInterfaceIdiom == .pad {
                Spacer(minLength: reader.size.height / 7) //Space between
            }
        }
    }
    
    //MARK: alcohol Consumed
    func alcoholConsumed() -> some View {
        return
            VStack {
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
    }
    
    func cup() -> String {
        if self.cups == 1 || self.cups == 0 {
            return "cup"
        } else {
            return "cups"
        }
    }
    
    //    func backgroundColor() -> some View {
    //        return  ZStack {
    //            LinearGradient(gradient: Gradient(colors: [backroundColorTop , backgroundColorBottom]), startPoint: .top, endPoint: .bottom)
    //                   .edgesIgnoringSafeArea(.vertical)
    //        }
    //    }
}

struct PopUp: View {
    
    @Binding var active: Bool
    @Binding var cups: Double
    @EnvironmentObject var user: UserRepository
    @EnvironmentObject var userDocument: UserDocument
    @StateObject var customDrinkDocument: CustomDrinkViewModel
    @State private var isDiuretic = false
    @State private var isPrecise = false
    @Environment(\.colorScheme) var colorScheme
    @Binding var waterColor: Color
    @Binding var isMetric: Bool
    @Binding var isCustomWater: Bool
    
    @State var isNavigationBarHidden: Bool = true
    
    //Background colors
    @Binding  var backgroundColorTop: Color
    @Binding  var backgroundColorBottom: Color
    
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
                ZStack{
                    LinearGradient(gradient: Gradient(colors: [backgroundColorTop , backgroundColorBottom]), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.vertical)
                    VStack {
                        HStack {
                            Spacer()
                            Button("Done", action: {
                                active = false
                            })
                            .padding()
                        }
                        NavigationLink(
                            
                            destination: ActionView()
                                .environmentObject(userDocument),
                            label: {
                                Text("Action Control")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .font(.system(size: 35))
                            })
                        Spacer()
                        HStack {
                            Text("Precise Control")
                                .font(.system(size: 35))
                            
                            Image(systemName: "figure.walk")
                                .padding()
                                .font(.system(size: 35))
                            
                        }
                        .onTapGesture {
                            isPrecise.toggle()
                        }
                        Spacer()
                        Text("Log diuretic")
                            .onTapGesture {
                                withAnimation() {
                                    isDiuretic.toggle()
                                }
                            }
                            .font(.system(size: 35))
                        
                        if isPrecise {
                            PreciseControl()
                        }
                        Spacer()
                        Text("Sign out")
                            .onTapGesture {
                                user.signOut()
                            }
                            .padding(.vertical)
                            .cornerRadius(23)
                            .font(.system(size: 35))
                        
                        
                        Spacer()
                    }
                }
                .navigationBarTitle("Action Control")
                .navigationBarHidden(self.isNavigationBarHidden)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .onAppear {
            isNavigationBarHidden = true
        }
        .sheet(isPresented: $isDiuretic, content: {
            DiureticView(cups: $cups, waterColor: $waterColor, isCustomWater: $isCustomWater, isMetric: $isMetric, isDiuretic: $isDiuretic, popUp: $active, isAlcoholConsumed: $isAlcoholConsumed, amountOfAccumulatedAlcohol: $amountOfAccumulatedAlcohol, percentageOfEachAlcohol: $percentageOfEachAlcohol, amountOfEachAlcohol: $amountOfEachAlcohol)
                .environmentObject(customDrinkDocument)
                .clearModalBackground()
                .edgesIgnoringSafeArea(.bottom)
        })
        
    }
}



