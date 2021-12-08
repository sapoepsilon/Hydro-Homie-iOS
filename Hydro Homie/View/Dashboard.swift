//
//  Dashboard.swift
//  Hydro Comrade
//
//  Created by Ismatulla Mansurov on 4/27/21.
//

import SwiftUI
import Firebase
import UserNotifications
import HealthKit
import PermissionsSwiftUINotification
import PermissionsSwiftUIHealth
import CoreData

enum sheet: String, Identifiable {
    var id: String {
        rawValue
    }
    case isDiuretic
    case isPopup
    case isDocumentAddition
    
}

struct Dashboard: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors:[ NSSortDescriptor(keyPath: \LocalHydration.id, ascending: true)]) var localHydration: FetchedResults<LocalHydration>
    @State var orientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation

    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    @AppStorage("welcomePage") var isWelcomePageShown: Bool = UserDefaults.standard.isWelcomePageShown
    @AppStorage("isFirstTimeLaunch") var isFirstTimeLaunch: Bool = UserDefaults.standard.isFirstTimeLaunch
    @AppStorage("isSyncFirebase") var isSyncFirebase: Bool = UserDefaults.standard.isSyncFirebase
    
    //user Exists, but document doesn't
    @State private var isUserExist: Bool = true
    @State private var previousWaterOpacity: Double = 1
    @State private var isLastCup: Bool = false
    @Binding var isDocumentAddition: Bool
    @Binding var isLoad: Bool
    @Environment(\.colorScheme) var colorScheme
    @StateObject var customDrinkDocument: CustomDrinkViewModel
    @EnvironmentObject var hydration: HydrationDocument
    @EnvironmentObject var user: UserRepository
    @EnvironmentObject var userDocument: UserDocument
    @State var cups: Double = 0
    @State private var cupsLeft: Double = 0
    var cupsArray: Array<Int> = Array()
    @State var percentageWater: Double = 0
    let formatter = NumberFormatter()
    @State private var offset = CGSize.zero
    @State private var previousOffset = CGSize.zero
    
    let timer = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
    @ObservedObject var displayLink = DisplayLink.sharedInstance
    @State var waterColor: Color =  Color( red: 0.09, green: 1, blue: 1, opacity: 1)
    @State var isCurrentHydration: Bool = true
    @State var waterViewOpacity: Double = 1
    @State var actionView: Bool = false
    @State private var actionOffset = CGSize.zero
    @State private var popUp: Bool = false
    @State var activeSheet: sheet?
    @State private var isDiuretic: Bool = false
    @State private var previosColor: Color = Color(red: 103 / 255, green: 146 / 255, blue: 103 / 255, opacity: 0.5)
    @State private var formattedFloat : String = ""
    @State private var cupsFormattedFloat: String = ""
    @State private var addCustomAmount: Bool = false
    @State private var waterScaleEffect: CGFloat = 1
    @State private var isInformation: Bool = false
    @State private var isCustomWater: Bool = false
    @State private var toolBackground: UIColor = UIColor(red: 103 / 255, green: 146 / 255, blue: 103 / 255, alpha: 0.5)
    // quick drink addition
    @State private var quickDrinkOpacity: Double = 1
    @State private var isQuickDrink: Bool = false
    @State private var waterBackgroundColor: Color = Color.black
    @State private var diureticCount: [Int] = []
    
    @State var isLocalTime: Bool = false
    @State var isLocalTimeAlcohol: Date = Date()
    
    // Coffee
    @State private var amountOfCoffee: Double = 0
    @State private var accumalatedAmountOfCoffee: Double = 0
    //alchol
    @State private var isCoffeeDrinker: Bool = false
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
    @State var currentHydrationDictionary: [String: [String:Double]] = ["": ["water": 0.0, "alcohol":0.0, "coffee":0.0]]
    @State var volumeMetric: String = "oz"
    @State var isMetric: Bool = false
    let today = format.string(from: Date())
    @ObservedObject var notificationTimerDocument = notificationTimeInterval
    @ObservedObject var alcoholTimer = timerBackground
    
    
    
    
    // delete later starts
    @State private var isSheet: Bool = false //delete later
    @State var water: String = ""
    @State var coffee: String = ""
    @State var alcohol: String = ""
    @State var currentHydrationID: NSManagedObjectID = NSManagedObjectID()
    //delete later ends
    @StateObject var timeCounter = TimeCounter()
    @State var dateChanger = Date()
    
    @State var newID: Int64 = 0
    @State var waveOffset = Angle(degrees: 0)

    
    
    // True if the data been fetched
    @State var isDataFetched: Bool = false
    
    @State var isPersmission: Bool = false
    let healthStore = HKHealthStore()
    let healthTypes = Set([HKSampleType.quantityType(forIdentifier: .dietaryWater)!, HKSampleType.quantityType(forIdentifier: .dietaryCaffeine)!])
    var isZoomed: Bool {
        return UIScreen.main.scale != UIScreen.main.nativeScale
    }
    let calendar = Calendar.current
    
//        var body: some View {
//            VStack {
//            HStack {
//                Button(action: {
//                    withAnimation {
//                    let newHydration = LocalHydration(context: viewContext)
//                        newHydration.water = Double.random(in: 1...20)
//                        newHydration.alcohol = Double.random(in: 1...20)
//                        newHydration.coffee = Double.random(in: 1...20)
//                        newHydration.id = newID
//                    newHydration.date = "today"
//                        newID += 1
//                        print("new id: \(newID)")
//                    do { try viewContext.save() } catch
//                         {
//                             let error = error as NSError
//                             fatalError("Unresolved Error: \(error)")
//                         }
//                    }
//                }, label: {Text("Add item")})
//                Spacer()
//                Button(action: {
//                    let item = localHydration[0]
//                    PersistenceController.shared.delete(object: item)
//                }, label: {
//                    Text("Delete item")
//                })
//            }
//            List {
//                ForEach(localHydration, id: \.self) { hydration in
//                    HStack{ Text("water \(hydration.water.rounded()),alcohol: \(hydration.isAlcoholLocalTime) coffee: \(hydration.coffee.rounded()), \(hydration.date ?? "no date") alcohol time: \(hydration.alcoholTimeDate)")                }.onTapGesture {
//                        hydration.water = 2
//                        hydration.date = "Updated by tapping"
//
//                    }
//                }
//            }
//        }.onAppear(perform: {
//
//            print(localHydration)
//        })
//        }
//    }
    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()
    var body: some View {
        ZStack {
                GeometryReader { reader in
                ZStack{
                    background()
                    VStack(spacing: isZoomed ? 0 : 5) {
                        HStack{
                            homeAction().scaleEffect(1.5)
                            Spacer()
                            if isLastCup && !actionView {
                                Button(action: {
                                    cancelTheLastDrink()
                                }, label: {
                                    Text("Cancel the last drink")
                                })
                            }
                            Spacer()
                            Button(action: {
                                activeSheet = .isPopup
                            }, label: {
                                Image(systemName: "gear").scaleEffect(1.5)
                            })
                        }.padding(.horizontal)
                        hydrationInfromation(reader: reader)
                        if !isAlcoholConsumed && !actionView && isCurrentHydration && orientation?.isPortrait ?? false {
                            UIDevice.current.userInterfaceIdiom == .pad ? Spacer().frame(height: reader.size.height / 10) : Spacer().frame(height: reader.size.height / 12)
                        }
                        if isAlcoholConsumed { alcoholConsumed(reader: reader)}
                        HStack{
                            if actionView {
                                VStack{ stats() }
                            }
                            else {
                                waterDrop(reader: reader)
                            }
                        }
                        //
                        if isCurrentHydration && !actionView {
                            withAnimation(){
                                Text("cups left today: \(formattedFloat)")
                                    .foregroundColor(colorScheme == .dark ? .gray : waterColor)
                                    .opacity(waterViewOpacity)
                                    .padding(.top)
                            }
                            //                            //MARK: Stepper
                            VStack {
                                stepper()
                                    .opacity(waterViewOpacity)
                                    .opacity(waterScaleEffect == 1.5 ? 0 : 1)
                                    .opacity(actionView ? 0 : 1)
                                notificationTimer()
                                    .opacity(actionView ? 0 : 1)
                                    .padding(.bottom, isZoomed ? -reader.size.height / 10 : 0)
                                if !notificationCountDown && UIDevice.current.userInterfaceIdiom == .pad && !isZoomed {
                                    Spacer()
                                }
                            }
                            //                                    .animation(.easeInOut)
                        }
                        if !isAlcoholConsumed || !actionView || !notificationCountDown || isCurrentHydration{
                            UIDevice.current.userInterfaceIdiom == .pad ? Spacer().frame(height: reader.size.height / 30) : Spacer().frame(height: reader.size.height / 14)                    }
                        HStack {

                            drop().offset(x: reader.size.width / 2)
                            Spacer()
                            plus().padding(.horizontal)
                        }                        .padding(.bottom , orientation?.isLandscape ?? false ? reader.size.height / 9 : 0)
                    }
                }
                .onAppear(perform: {
                    isPersmission.toggle()
                })
                //                .JMModal(showModal: $isPersmission, for: UIDevice.current.userInterfaceIdiom == .pad ? [.notification] : [.notification, .health(categories: .init(write: healthTypes))], restrictDismissal: true)
                .JMAlert(showModal: $isPersmission, for: UIDevice.current.userInterfaceIdiom == .pad ? [.notification] : [.notification, .health(categories: .init(write: healthTypes))],restrictDismissal: false, autoDismiss: true)
                .changeHeaderTo(UIDevice.current.userInterfaceIdiom == .pad ? "Notification access" : "Health App and Notification access")
                .changeHeaderDescriptionTo("Hydro Comrade needs the notification access to inform you when is the right time for your next drink.")
                .changeBottomDescriptionTo(
                    UIDevice.current.userInterfaceIdiom != .pad ?     "Hydro Comrade also needs the access to your Health app. So, it can synchronize all your water and caffeine consumption." : "")
                .navigationViewStyle(StackNavigationViewStyle())
                Background(percentageOfEachAlcohol: $percentageOfEachAlcohol, amountOfAccumulatedAlcohol: $amountOfAccumulatedAlcohol, isAlcoholConsumed: $isAlcoholConsumed, cups: $cups, backgroundOpacity: $backgroundOpacity, isQuickDrink: $isQuickDrink,   isFirstMenu: $isFirstMenu, amountOfEachAlcohol: $amountOfEachAlcohol, coffeeAmount: $amountOfCoffee, accumulatedCoffeeAmount: $accumalatedAmountOfCoffee )
                    .environmentObject(customDrinkDocument)
                    .opacity(isQuickDrink ? 1 : 0)
            }
        }.clipped()
            .onReceive(orientationChanged) { _ in
                self.orientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation
            }
        .onAppear{
          

            userDocument.fetchData(completionHandler: { (isLoadView, fetchErrorMessage) in
                if isLoadView {
                    isLoad = false
                    isDataFetched = true
                    print(fetchErrorMessage)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        print("Coffee starting to execute")
                        self.cups = getLocalCups()
                        self.isDiureticMode = getLocalDiuretic()
                        self.amountOfAccumulatedAlcohol = getLocalAlcohol()
                        self.accumalatedAmountOfCoffee = getLocalCoffee()
                        self.isLocalTime = getLocalDiuretic()
                        self.isLocalTimeAlcohol = getLocalAlcoholTime()
                    }
                    self.isMetric = userDocument.user.metric
                    let cupsDate = Date()
                    format.dateFormat = "yyyy-MM-dd"
                    let today = format.string(from: cupsDate)
                    self.currentHydrationDictionary = userDocument.user.hydration.last ?? [today: ["water": 0.0, "alcohol":0.0, "coffee":0.0]]
                    self.userName = userDocument.getUser().name
                    self.waterIntake = userDocument.getUser().waterIntake
                    self.hydrationDate = userDocument.getTheLatestDate()
                    self.cupsLeft = waterIntake / Double(cupConverter())
                    self.cupsLeft -= cups
                    print("oafter change \(userName)")
                    isLoad = false
                    if(userDocument.user.metric == true) {
                        volumeMetric = "ml"
                    }
                } else {
                    print(fetchErrorMessage)
                    userDocument.fetchData(completionHandler: { (isLoadView, fetchErrorMessage) in
                        if isLoadView {
                            isLoad = false
                            isDataFetched = true
                        } else {
                            activeSheet = .isDocumentAddition
                        }
                    })
                }
            })
            customDrinkDocument.getAllDrinks()
            customDrinkDocument.getDrinkOpacity()
            UIToolbar.appearance().setBackgroundColor(image: UIImage(color: .clear, size: CGSize(width: 100, height: 44.0))!)
            waterBackgroundColor = backgroundColorTop
            waterColor = currentWaterColor(colorScheme: colorScheme)
            isCoffeeDrinker = userDocument.user.isCoffeeDrinker
            let components = calendar.dateComponents([.day], from: dateChanger)
            let dayOfMonth = components.day
            UserDefaults.standard.set(dayOfMonth, forKey: "dateChanger")
            if colorScheme == .dark {
                backgroundColorTop = Color(red: 63/255, green: 101/255, blue: 131/255, opacity: 51/100)
                backgroundColorBottom = Color(red: 115/255, green: 116/255, blue: 117/255, opacity: 46/100)
            } else {
                backgroundColorTop = Color(red: 148/255, green: 189/255, blue: 227/255, opacity: 89/100)
                backgroundColorBottom = Color(red: 197/255, green: 197/255, blue: 237/255, opacity: 93/100)
            }
        }
        .onReceive(timeCounter.$time, perform: { val in
            //check if the date has changed
            let lastDate = UserDefaults.standard.integer(forKey: "dateChanger")
            let newDate = Date()
            let components = calendar.dateComponents([.day], from: newDate)
            let dayOfMonth = components.day
            if lastDate != dayOfMonth ?? 0 {
                self.cups = getLocalCups()
                self.isDiureticMode = getLocalDiuretic()
                self.amountOfAccumulatedAlcohol = getLocalAlcohol()
                self.accumalatedAmountOfCoffee = getLocalCoffee()
                UserDefaults.standard.set(dayOfMonth, forKey: "dateChanger")
            }
        })
        
        .onChange(of: userDocument.user.name, perform: { newValue in
            self.isMetric = userDocument.user.metric
            let cupsDate = Date()
            format.dateFormat = "yyyy-MM-dd"
            let today = format.string(from: cupsDate)
            self.currentHydrationDictionary = userDocument.user.hydration.last ?? [today: ["water": 0.0, "alcohol":0.0, "coffee":0.0]]
            self.userName = userDocument.getUser().name
            self.waterIntake = userDocument.getUser().waterIntake
            self.hydrationDate = userDocument.getTheLatestDate()
            self.cupsLeft = waterIntake / Double(cupConverter())
            self.cupsLeft -= cups
            isLoad = false
            if(userDocument.user.metric == true) {
                volumeMetric = "ml"
            }
        })
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .isDiuretic:
                ZStack {
                    DiureticView(onCompleteBlock: { self.activeSheet = nil }, cups: $cups, waterColor: $waterColor, isCustomWater: $isCustomWater, isMetric: $isMetric, isDiuretic: $isDiuretic, popUp: $popUp, isAlcoholConsumed: $isAlcoholConsumed, amountOfAccumulatedAlcohol: $amountOfAccumulatedAlcohol, percentageOfEachAlcohol: $percentageOfEachAlcohol, amountOfEachAlcohol: $amountOfEachAlcohol, coffeeAmount: $amountOfCoffee ,accumulatedCoffeeAmount: $accumalatedAmountOfCoffee)
                        .environmentObject(customDrinkDocument)
                        .edgesIgnoringSafeArea(.bottom)
                        .clearModalBackground()
                }
            case .isPopup:
                NavigationView {
                    PopUp(onCompleteBlock: { self.activeSheet = nil }, active: $popUp, cups: $cups, customDrinkDocument: customDrinkDocument, waterColor: $waterColor, isMetric: $isMetric, isCustomWater: $isCustomWater, backgroundColorTop: $backgroundColorTop, backgroundColorBottom: $backgroundColorBottom, isAlcoholConsumed: $isAlcoholConsumed, percentageOfAlcohol: $percentageOfAlcohol, percentageOfEachAlcohol: $percentageOfEachAlcohol, amountOfEachAlcohol: $amountOfEachAlcohol, amountOfAccumulatedAlcohol: $amountOfAccumulatedAlcohol, coffeeAmount: $amountOfCoffee, accumulatedCoffeeAmount: $accumalatedAmountOfCoffee)
                        .clearModalBackground()
                        .environmentObject(customDrinkDocument)
                        .environmentObject(user)
                        .environmentObject(userDocument)
                        .edgesIgnoringSafeArea(.bottom)
                }
            case .isDocumentAddition:
                RegisterView(isUserExist: $isUserExist, onCompleteBlock: {activeSheet = nil
                    isLoad = false
                    userDocument.fetchData(completionHandler: { (isLoadView, fetchErrorMessage) in
                        if isLoadView {
                            isLoad = false
                            isDataFetched = true

                            print(fetchErrorMessage)
                            self.isMetric = userDocument.user.metric
                            let cupsDate = Date()
                            format.dateFormat = "yyyy-MM-dd"
                            let today = format.string(from: cupsDate)
                            self.currentHydrationDictionary = userDocument.user.hydration.last ?? [today: ["water": 0.0, "alcohol":0.0, "coffee":0.0]]
                            self.userName = userDocument.getUser().name
                            self.waterIntake = userDocument.getUser().waterIntake
                            self.hydrationDate = userDocument.getTheLatestDate()
                            self.cupsLeft = waterIntake / Double(cupConverter())
                            self.cupsLeft -= cups
                            print("oafter change \(userName)")
                            isLoad = false
                            if(userDocument.user.metric == true) {
                                volumeMetric = "ml"
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                print("Coffee starting to execute")
                                self.cups = getLocalCups()
                                self.isDiureticMode = getLocalDiuretic()
                                self.amountOfAccumulatedAlcohol = getLocalAlcohol()
                                self.accumalatedAmountOfCoffee = getLocalCoffee()
                            }
                        } else {
                            print(fetchErrorMessage)
                            userDocument.fetchData(completionHandler: { (isLoadView, fetchErrorMessage) in
                                if isLoadView {
                                    isLoad = false
                                    isDataFetched = true

                                } else {
                                    activeSheet = .isDocumentAddition
                                }
                            })
                        }


                    })
                }, isLoad: $isLoad, Dashboard: $user.loggedIn, registerView: $isDocumentAddition )
            }

        }
        .onChange(of: userDocument.enumDocument, perform: { value in
            if value == .doesNotExist {
                isDocumentAddition = true
                activeSheet = .isDocumentAddition
            } else {
                isDocumentAddition = false
            }
        })
        .onChange(of: colorScheme, perform: { value in
            waterBackgroundColor = backgroundColorTop
            waterColor = currentWaterColor(colorScheme: colorScheme)
            waterBackgroundColor = backgroundColorTop
        })
        .onChange(of: amountOfEachAlcohol, perform: { value in
            if value != 0 {
                diureticCount.append(Int(amountOfEachAlcohol))
            }
        })
        .onChange(of: amountOfCoffee, perform: { value in
            if amountOfCoffee != 0 {
                addCaffeineToHK(caffeine: value)
            }
        })
        .onChange(of: isDiureticMode, perform: { value in
            waterColor = currentWaterColor(colorScheme: colorScheme)
            if accumalatedAmountOfCoffee != getLocalCoffee() || amountOfAccumulatedAlcohol != getLocalAlcohol() {
                addWaterLocalHydration(cups: cups, alcohol: amountOfAccumulatedAlcohol, coffee: accumalatedAmountOfCoffee, isDiureticMode: isDiureticMode, isLocalTime: true)
            }
            if isDiureticMode {
                isAlcoholConsumed = true
            }
        })
        .onChange(of: self.currentHydrationDictionary, perform: { newValue in
            for hydration in currentHydrationDictionary {
                self.hydrationDate = hydration.key
            }

            waterColor = currentWaterColor(colorScheme: colorScheme)
            isCurrentHydration = true


            format.dateFormat = "MMM d, yyyy"
            let cupsDate = Date()
            //                        self.cups = hydration.getCups(hydrationDictionary: currentHydrationDictionary, lastHydration: userDocument.user.hydration.last ?? [today : ["": 0]])
            //            self.calculatedPercentage = userDocument.waterPercentageCalculator(hydrationDictionary: currentHydrationDictionary)
            //                        let percentageWaterMultiply = ((100 / (Int(waterIntake) / cupConverter())) * calculatedPercentage)
            //                        percentageWater = Double(percentageWaterMultiply)
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
        .onChange(of: notificationCountDown, perform: { _ in
            if notificationCountDown {
                isLastCup = true
            } else {
                isLastCup = false
            }
        })
        .onChange(of: colorScheme, perform: { _ in
            if colorScheme == .dark {
                backgroundColorTop = Color(red: 63/255, green: 101/255, blue: 131/255, opacity: 51/100)
                backgroundColorBottom = Color(red: 115/255, green: 116/255, blue: 117/255, opacity: 46/100)
            } else {
                backgroundColorTop = Color(red: 148/255, green: 189/255, blue: 227/255, opacity: 89/100)
                backgroundColorBottom = Color(red: 197/255, green: 197/255, blue: 237/255, opacity: 93/100)
            }
        })
        .onChange(of: isDataFetched, perform: { isFetched in
            if isFetched {
                if !isSyncFirebase {
                    syncLocalWithFirebase()
                }
            }
        })
        .onChange(of: self.cups, perform: { value in
            let cupsDate = Date()
            format.dateFormat = "yyyy-MM-dd"
            let today = format.string(from: cupsDate)
            let lastCup = UserDefaults.standard.double(forKey: "cups")
            previousCup = cups - lastCup
            percentageWater = (100 / ((waterIntake) / Double(cupConverter())) * self.cups)
            //upload the hydration to Firebase starting the second day:
            if localHydration.count > 2 && isDataFetched {
                hydration.updateHydration(hydration: localHydration)
            } // end of the Hydration update to the Firebase.
            cupsLeft = (waterIntake / Double(cupConverter())) - cups
            formattedFloat = String(format: "%.1f", cupsLeft)
            cupsFormattedFloat = String(format: "%.1f", cups)
            cupLocal()
            addWaterAmountToHealthKit(ounces: (previousCup * 8))
            if amountOfCoffee != 0 {
                addCaffeineToHK(caffeine: amountOfCoffee)
                if !isCoffeeDrinker {
                    if accumalatedAmountOfCoffee >= 500 {
                        isDiureticMode = true
                    }
                }
            }
            isFirstTimeLaunch = true

            if amountOfAccumulatedAlcohol != getLocalAlcohol() {
                addWaterLocalHydration(cups: cups, alcohol: amountOfAccumulatedAlcohol, coffee: accumalatedAmountOfCoffee, isDiureticMode: isDiureticMode, isLocalTime: true)
            } else {
                addWaterLocalHydration(cups: cups, alcohol: amountOfAccumulatedAlcohol, coffee: accumalatedAmountOfCoffee, isDiureticMode: isDiureticMode, isLocalTime: false)
            }
        })
        .onChange(of: colorScheme, perform: { _ in
            if colorScheme == .dark {
                backgroundColorTop = Color(red: 148/255, green: 189/255, blue: 227/255, opacity: 89/100)
                backgroundColorBottom = Color(red: 197/255, green: 197/255, blue: 237/255, opacity: 93/100)
                waterColor = currentWaterColor(colorScheme: colorScheme)

            } else {
                waterColor = currentWaterColor(colorScheme: colorScheme)
                backgroundColorTop = Color(red: 63/255, green: 101/255, blue: 131/255, opacity: 51/100)
                backgroundColorBottom = Color(red: 115/255, green: 116/255, blue: 117/255, opacity: 46/100)
                toolBackground = UIColor(backgroundColorBottom)
                //                UIToolbar.appearance().setBackgroundColor(image: UIImage(color: .red, size: CGSize(width: UIScreen.main.bounds.width, height: 34))!)
            }
        })

        .onChange(of: amountOfAccumulatedAlcohol, perform: { value in
            if amountOfAccumulatedAlcohol != 0 {
                var amountOfExtraWater: Double = 0
                if self.percentageOfEachAlcohol > 10 || self.amountOfAccumulatedAlcohol > 30 {
                    amountOfExtraWater = amountOfEachAlcohol / 14
                    withAnimation {
                        isDiureticMode  = true
                        waterColor = currentWaterColor(colorScheme: colorScheme)
                        waterIntake += (Double(cupConverter()) * amountOfExtraWater)
                        UserDefaults.standard.set((Double(cupConverter()) * amountOfExtraWater), forKey: "extraWater")
                    }
                }
            }
        
        })

        .alert(isPresented: $isInformation, content: {
            Alert(title: Text("Diuretic effect"), message:
                    Text(isDiureticMode ? "Alcohol is a diuretic, which means it promotes water loss through urine. It does this by inhibiting the production of a hormone called vasopressin, which plays a large role in the regulation of water excretion." : "Small amounts of alcohol in your drink hydrates your body as much as water does." )
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
                .aspectRatio(orientation?.isPortrait ?? false ? 1 : 2/3, contentMode: .fit)

        }
    }

    func getDictionaryFromNested(dictionary: [String: [String:Double]]) -> [String:Double] {
        var returnDictionary: [String:Double] = ["": 0.0]
        for goodDictionary in dictionary.values {
            returnDictionary = goodDictionary
        }
        return returnDictionary
    }

    func calculateNotificationInterval(waterIntake: Double, awakeness: Double) -> Double {
        let minutes: Double = 60
        let seconds: Double = 60
        var notificationInterval = ((awakeness / waterIntake) * minutes) * seconds
        notificationInterval *= previousCup
        return notificationInterval
    }

    func background() -> some View {
        return LinearGradient(gradient: Gradient(colors: [backgroundColorTop , backgroundColorBottom]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.vertical)
    }

    func currentWaterColor(colorScheme: ColorScheme) -> Color {
        var waterColor: Color = Color( red: 0, green: 0, blue: 0, opacity: 0)

        if !isDiureticMode {
            if colorScheme == .light { waterColor = Color( red: 0, green: 0.5, blue: 0.8, opacity: 1) }
            else { waterColor = Color( red: 0, green: 0.5, blue: 0.7, opacity: 1) }
        } else {
            waterColor = Color(red: 130 / 255, green: 98 / 255, blue: 222 / 255, opacity: 0.5)
        }
        return waterColor
    }

    /// Store all the data from firebase locally.
    ///
    /// - Author: Ismatulla Mansurov
    ///
    /// - Returns: No return
    ///
    /// - Throws: Completion handler, can accept Boolean, which
    /// shows if the sync was succseful
    ///     ///
    /// - Parameters:
    ///     - hydration document: [String: [String: Double]]
    ///
    ///  - Note:[Reference](https://stackoverflow.com)
    ///
    ///  - Important: make sure to do something ....
    ///
    ///  - Summary: sdfsdfdsf
    ///
    ///  - Version: 0.1
    ///
    func syncLocalWithFirebase() {
        var localID: Int64 = 0
        let hydrationSyncRemoteToLocal =  userDocument.user.hydration
        for dictionary in hydrationSyncRemoteToLocal {


            for eachDictionary in dictionary {

                let newLocalHydration = LocalHydration(context: viewContext)
                print(eachDictionary.key)

                for (name, cups) in eachDictionary.value {
                    if name != "water" {
                        name == "alcohol" ? newLocalHydration.alcohol + cups : newLocalHydration.coffee + cups
                    } else {
                        newLocalHydration.coffee = cups
                    }
                }
                newLocalHydration.date = eachDictionary.key
                newLocalHydration.id = localID
                localID += 1
                print("synced hydration from the firebase to local SQL: \(newLocalHydration.description)")
                saveContext()
            }
        }
        isSyncFirebase = true
    }
    func plus() -> some View {
        return Menu(content: {
            ForEach(customDrinkDocument.customDrinks, id: \.self   ) { liquid in
                Button(action: {
                    if liquid.isAlcohol {
                        amountOfAccumulatedAlcohol += liquid.alcoholAmount
                        percentageOfEachAlcohol = liquid.alcoholPercentage
                        amountOfEachAlcohol = liquid.alcoholAmount
                        cups += liquid.amount
                    } else if liquid.isCaffeine {
                        accumalatedAmountOfCoffee += liquid.caffeineAmount
                        amountOfCoffee = liquid.caffeineAmount
                        cups += liquid.amount
                    } else if liquid.isCustomWater  {
                        cups += liquid.amount
                    }
                }, label: {
                    Text(liquid.name)
                })
            }
        }, label: {
            Text("Custom Drinks")
        })
//                withAnimation() {
//                    isQuickDrink.toggle()
//                    if isQuickDrink {
//                        backgroundOpacity = 0.6
//                        isFirstMenu = true
//                    } else {
//                        backgroundOpacity = 0.00
//                    }
//                }
//    }
    }
    //MARK: Quick Menu functions

    func drop() -> some View {
        return Image(systemName: "drop")
            .scaleEffect(2)
            .onTapGesture {
                withAnimation() {
                    activeSheet = .isDiuretic
                }
            }
            .opacity(actionView ? 0 : 1)
    }

    //MARK: HOME ACTION
    func homeAction() -> some View {
        return Button(action: {
            let cupsDate = Date()
            format.dateFormat = "yyyy-MM-dd"
            let today = format.string(from: cupsDate)
            withAnimation(.linear(duration: 0.40)){
                isCurrentHydration = true
                waterColor = currentWaterColor(colorScheme: colorScheme)
                actionView = false
                hydrationDate = userDocument.getTheLatestDate()
                currentHydrationDictionary = userDocument.user.hydration.last ?? [today: ["":0]]
                waterViewOpacity = 1
                offset = CGSize.zero
            }
        }, label: {
            Image(systemName: "house")
        })
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


    
    func addWaterLocalHydration(cups: Double, alcohol: Double, coffee: Double, isDiureticMode: Bool, isLocalTime: Bool) {

        let cupsDate = Date()
        format.dateFormat = "MMM d, yyyy"
        let today = format.string(from: cupsDate)
        let lastObject = localHydration.last
        
        if lastObject?.date != today && !localHydration.isEmpty {
            var newId = lastObject?.id ?? 0
            newId += 1
            let newLocalHydration = LocalHydration(context: viewContext)
            newLocalHydration.water = cups
            newLocalHydration.coffee = coffee
            newLocalHydration.alcohol = alcohol
            newLocalHydration.date = today
            newLocalHydration.id = newId
            newLocalHydration.isDiureticMode = isDiureticMode
            newLocalHydration.isAlcoholLocalTime = isDiureticMode
            if isLocalTime{
                newLocalHydration.alcoholTimeDate = cupsDate
            }
            saveContext()
        } else {
            lastObject?.alcohol = alcohol
            lastObject?.water = cups
            lastObject?.coffee = coffee
            lastObject?.isDiureticMode = isDiureticMode
            if isLocalTime {
                lastObject?.alcoholTimeDate = cupsDate
            }
            saveContext()
        }
    }

    func saveContext()
    {
        do { try viewContext.save() } catch
        {
            let error = error as NSError
            fatalError("Unresolved Error: \(error)")
        }
    }

    func deleteLastLocalHydration()
    {
        if localHydration.last != nil {
            viewContext.delete(localHydration.last!)
        }
    }

    func getLocalCups() -> Double {
        let cupsDate = Date()
        format.dateFormat = "MMM d, yyyy"
        let today = format.string(from: cupsDate)
        let localHydration = localHydration.last
        if localHydration?.date != today {
            return 0
        } else {
            return localHydration?.water ?? 0
        }
    }

    func getLocalAlcohol() -> Double {
        let cupsDate = Date()
        format.dateFormat = "MMM d, yyyy"
        let today = format.string(from: cupsDate)
        let localHydration = localHydration.last
        if localHydration?.date != today {
            return 0
        } else {
            return localHydration?.alcohol ?? 0
        }
    }
    
    func getLocalAlcoholTime() -> Date {
        let cupsDate = Date()
        format.dateFormat = "MMM d, yyyy"
        let today = format.string(from: cupsDate)
        let localHydration = localHydration.last
        if localHydration?.date != today {
            return Date()
        } else {
            return localHydration?.alcoholTimeDate ?? Date()
        }
    }

    func getLocalDiuretic() -> Bool {
        let cupsDate = Date()
        format.dateFormat = "MMM d, yyyy"
        let today = format.string(from: cupsDate)
        let localHydration = localHydration.last
        if localHydration?.date != today {
            return false
        } else {
            return localHydration?.isDiureticMode ?? false
        }
    }

    func getLocalCoffee() -> Double {
        let cupsDate = Date()
        format.dateFormat = "MMM d, yyyy"
        let today = format.string(from: cupsDate)
        let localHydration = localHydration.last
        if localHydration?.date != today {
            return 0
        } else {
            return localHydration?.coffee ?? 0
        }
    }

    func cupLocal() {
        if isCurrentHydration {
            let waterIntakeConverted = waterIntake / Double(cupConverter())
            let cuplocal = UserDefaults.standard.double(forKey: "cups")
            UserDefaults.standard.set(cuplocal, forKey: "previousDrink")
            if cups > cuplocal && cups != 0 {
                let updateTheTimerView = cups - cuplocal
                if updateTheTimerView == 1 {
                    let number = Int.random(in: 0..<10)
                    notificationInterval -= Double(number)
                }
                if isFirstTimeLaunch {
                    if cups != getLocalCups() {
                        notificationInterval = calculateNotificationInterval(waterIntake: waterIntakeConverted, awakeness: 16)
                        hydration.addNotification(timeInterval: notificationInterval)
                        notificationCountDown = true
                    }
                }
            }
            UserDefaults.standard.set(cups, forKey: "cups")
        }
    }
    func cancelTheLastDrink() {
        let previousCups = UserDefaults.standard.double(forKey: "previousDrink")
        let amountOfExtraWater = UserDefaults.standard.double(forKey: "extraWater")
        print("previous Drink amount: \(previousCups)")
        print("Current cups amount: \(cups)")
        cups = previousCups
        if(diureticCount.count == 1) {
            isDiureticMode = false
            isAlcoholConsumed = false
            waterIntake -= amountOfExtraWater
            amountOfEachAlcohol = 0
            amountOfAccumulatedAlcohol = 0
            diureticCount.removeLast() }
        else if diureticCount.count >= 2 {
            amountOfAccumulatedAlcohol -= amountOfEachAlcohol
            amountOfEachAlcohol = 0
            waterIntake -= amountOfExtraWater
            diureticCount.removeLast() }
        deleteLastLocalHydration()
        hydration.removeNotification()
        notificationCountDown = false
        waterColor = currentWaterColor(colorScheme: colorScheme) }
    func cupConverter() -> Int {
        var cupConverter: Int = 1
        if isMetric { cupConverter = 237 } else { cupConverter = 8 }
        return cupConverter
    }

    func addCaffeineToHK(caffeine: Double) {
        let caffeineQuantityType = HKQuantityType.quantityType(forIdentifier: .dietaryCaffeine)
        let caffeineQuantityUnit = HKUnit(from: .gram)
        let caffeineQuantityAmount = HKQuantity(unit: caffeineQuantityUnit, doubleValue: caffeine)
        let now = Date()
        let sample = HKQuantitySample(type: caffeineQuantityType!, quantity: caffeineQuantityAmount, start: now, end: now)
        let correlationType = HKObjectType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.food)
        let waterCorrelationForWaterAmount = HKCorrelation(type: correlationType!, start: now, end: now, objects: [sample])
        // Send water intake data to healthStore…aka ‘Health’ app
        // 5
        self.healthStore.save(waterCorrelationForWaterAmount, withCompletion: { (success, error) in
            if (error != nil) { NSLog(String("error occurred saving water data")) }
        })
    }

    func addWaterAmountToHealthKit(ounces : Double) {
        let quantityType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)
        let quanitytUnit = HKUnit(from: "fl_oz_us")
        let quantityAmount = HKQuantity(unit: quanitytUnit, doubleValue: ounces)
        let now = Date()
        let sample = HKQuantitySample(type: quantityType!, quantity: quantityAmount, start: now, end: now)
        let correlationType = HKObjectType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.food)
        let waterCorrelationForWaterAmount = HKCorrelation(type: correlationType!, start: now, end: now, objects: [sample])
        self.healthStore.save(waterCorrelationForWaterAmount, withCompletion: { (success, error) in if (error != nil) { NSLog(String("error occurred saving water data"))} })
    }

    func waterDrop(reader: GeometryProxy) -> some View {
        return VStack {
            WaterView(factor: self.percentageWater, waterColor: $waterColor, backgroundColor: $waterBackgroundColor)
                .opacity(waterViewOpacity)
        }
        .frame(width: reader.size.width, height: reader.size.height / 2)
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
                    activeSheet = .isDiuretic
                }
            }
        }
        .shadow(color: colorScheme == .dark ? .white : .black, radius: 6)
        .offset(x: offset.width * 5, y: offset.height * 5)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if waterScaleEffect == 1 {
                        self.offset.width = gesture.translation.width / 3
                        self.offset.height = gesture.translation.height / 3
                    } else {
                        self.cups = Double((-gesture.translation.height / 50))
                    }

                }
                .onEnded { _ in

                    if offset.height >= -45 && offset.height < 0 {
                        offset.height = 0
                    }
                    if offset.height < -40 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            offset.height = 230
                        }
                        withAnimation(.linear(duration: 0.5)) {
                            actionView = true
                        }
                    }
                    if offset.width != 0  {
                        offset.width = 0
                        offset.height = 0
                    }
                })
        .onChange(of: offset, perform: { value in

            print("value right now \(value)")
            if offset.width < -249 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    offset.width = 0
                    waterViewOpacity = 1
                }
            } else if offset.width > 249 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    offset.width = 0
                    waterViewOpacity = 1
                }
            }
            if offset.height < -30 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    offset.width = 0
                    waterViewOpacity = 1
                }
            }
        })
    }

    //MARK: Display stats
    func stats() -> some View {
        return  ActionView(backgroundColorTop: $backgroundColorTop, backgroundColorBottom: $backgroundColorBottom, isMetric: $isMetric)//display the ActionView when the user swipes up
            .offset(x: actionOffset.width * 5, y: actionOffset.height * 5)
            .frame(width: UIScreen.main.bounds.width - 20)
            .environmentObject(userDocument)
            .environment(\.managedObjectContext, viewContext)
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
                            withAnimation(.linear(duration: 0.5)) {
                                //                                waterViewOpacity = 1 // if the user swipes right waterView disappears
                                actionView.toggle()
                                offset = CGSize.zero
                            }
                        } else {
                            actionOffset = CGSize.zero
                        }

                    })
            .onChange(of: displayLink.frameChange) { time in
                for _ in 0...10 {
                    if actionOffset.height > 1 {
                        actionOffset.height -= 1.2
                    } else if offset.height > 1 {
                        offset.height -= 1
                    }
                }
            }
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
                    .font(Font.title.bold())
                Spacer().frame(height: orientation?.isPortrait ?? false ? reader.size.height / 20 : 0)
            }
        }
    }

    //MARK: alcohol Consumed
    func alcoholConsumed(reader: GeometryProxy) -> some View {
        return  VStack {
            HStack {
            Text(isDiureticMode ? "Diuretic mode is on" : "Alchol mode is on")
                .foregroundColor(waterColor)
                .font(.system(.headline))
   
            }
            HStack {
                    AlcoholTimer(isDiureticMode: $isDiureticMode, waterColor: $waterColor,localTimeLeft: $isLocalTimeAlcohol, isLocalTime: $isLocalTime)
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
}

struct PopUp: View {

    @State var onCompleteBlock: (() -> Void)
    @Binding var active: Bool
    @Binding var cups: Double
    @State private var colorScheme: ColorScheme = .dark
    @EnvironmentObject var user: UserRepository
    @EnvironmentObject var userDocument: UserDocument
    @StateObject var customDrinkDocument: CustomDrinkViewModel
    @State private var isDiuretic = false
    @State private var isPrecise = false
    @Binding var waterColor: Color
    @Binding var isMetric: Bool
    @Binding var isCustomWater: Bool

    @State var isNavigationBarHidden: Bool = true

    //Background colors
    @Binding  var backgroundColorTop: Color
    @Binding  var backgroundColorBottom: Color


    @AppStorage ("log_status") var appleLogStatus = false
    @AppStorage ("appleName") var appleName: String = ""
    @AppStorage ("appleEmail") var appleEmail: String = ""
    @AppStorage ("appleUID") var appleUID: String = ""
    //Alcohol
    @Binding var isAlcoholConsumed: Bool
    @Binding var percentageOfAlcohol: Double
    @Binding var percentageOfEachAlcohol: Double
    @Binding var amountOfEachAlcohol: Double
    @Binding var amountOfAccumulatedAlcohol: Double
    @State private var isDarkMode: Bool = false
    @State private var actionControlColor: Color = Color.black
    @Binding var coffeeAmount: Double
    @Binding var accumulatedCoffeeAmount: Double


    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [backgroundColorTop , backgroundColorBottom]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            NavigationView {
                VStack {

                    HStack {
                        Spacer()
                        Button("Done", action: {
                            active = false
                            onCompleteBlock()
                        }).padding()
                    }
                    NavigationLink(
                        destination: ActionView(backgroundColorTop: $backgroundColorTop, backgroundColorBottom: $backgroundColorBottom, isMetric:$isMetric)
                            .environmentObject(userDocument),label: {Text("Action Control").font(.system(size: 35))})
                        .onTapGesture { isPrecise.toggle()}
                    Spacer()

                    Text("Log diuretic")
                        .onTapGesture { withAnimation() { isDiuretic.toggle() } }
                        .font(.system(size: 35))
                    Spacer()

                    Text("Sign out")

                        .onTapGesture {
                            user.signOut()
                            appleLogStatus = false
                            appleUID = ""
                            appleName = ""
                            appleEmail = ""
                        }

                        .padding(.vertical)
                        .cornerRadius(23)
                        .font(.system(size: 35))
                    Spacer()

                }
                .navigationBarHidden(self.isNavigationBarHidden)

            }

            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarHidden(true)
            .onAppear {
                isNavigationBarHidden = true
                if colorScheme == .dark {
                    isDarkMode = true
                    actionControlColor = .white
                } else {
                    isDarkMode = false
                }
            }
        }
        .onChange(of: isDarkMode, perform: { value in
            if isDarkMode {
                colorScheme = .dark
            } else {
                colorScheme = .light
            }
        })
        .sheet(isPresented: $isDiuretic, content: {
            DiureticView(onCompleteBlock: {}, cups: $cups, waterColor: $waterColor, isCustomWater: $isCustomWater, isMetric: $isMetric, isDiuretic: $isDiuretic, popUp: $active, isAlcoholConsumed: $isAlcoholConsumed, amountOfAccumulatedAlcohol: $amountOfAccumulatedAlcohol , percentageOfEachAlcohol: $percentageOfEachAlcohol, amountOfEachAlcohol: $amountOfEachAlcohol, coffeeAmount: $coffeeAmount, accumulatedCoffeeAmount: $accumulatedCoffeeAmount)
                .environmentObject(customDrinkDocument)
                .clearModalBackground()
                .edgesIgnoringSafeArea(.bottom)
        })
    }
}

