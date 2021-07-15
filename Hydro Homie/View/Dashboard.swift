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
    @State  private var previosColor: Color = Color(red: 103 / 255, green: 146 / 255, blue: 103 / 255, opacity: 0.5)
    @State private var formattedFloat : String = ""
    @State private var addCustomAmount: Bool = false
    @State private var waterScaleEffect: CGFloat = 1
    
    // MARK: User information
    @State var userName: String = ""
    @State var waterIntake: Double = 1
    @State var hydrationDate: String = ""
    @State var calculatedPercentage: Int = 1
    @State var currentHydrationDictionary: [String: Int] = ["": 1]
    @State var volumeMetric: String = "oz"
    @State var isMetric: Bool = false
    
    
    
    @ViewBuilder
    var body: some View {
        GeometryReader { reader in
            NavigationView {
                VStack{
                    if isCurrentHydration {
                        Text("\(userName), your daily goal: \( formatter.string(from: NSNumber(value: waterIntake))!) \(volumeMetric)")
                            .font(.system(size: reader.size.height / 35, weight: .heavy))
                            .foregroundColor(colorScheme == .dark ? Color.gray : waterColor)
                    } else {
                        Text("You have drank \(formattedFloat) on: \(hydrationDate)")
                            .foregroundColor(colorScheme == .dark ? .gray : waterColor)
                            .font(.system(size: reader.size.height / 40, weight: .heavy))
                    }
                    
                    Spacer(minLength: reader.size.height / 6)
                    
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
                                    .onReceive(timer, perform: {time in
                                        if actionOffset.height > 1 {
                                            actionOffset.height -= 1
                                        }
                                    })
                            }
                        } else {
                            WaterView(factor: self.$percentageWater, waterColor: $waterColor)
                                .frame(height: reader.size.height / 2)
                                .scaleEffect(waterScaleEffect)
                                .onTapGesture {
                                    if waterScaleEffect == 1.5 {
                                        waterScaleEffect = 1
                                        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                                        impactHeavy.impactOccurred()
                                    } else {
                                        if isCurrentHydration{
                                            let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                                            impactHeavy.impactOccurred()
                                            isDiuretic = true
                                                
                                            //                                            cups += 1
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
                                .opacity(waterViewOpacity - Double(abs(offset.width / 50)))
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
                            Text("cups left today: \(formattedFloat )")
                                .foregroundColor(colorScheme == .dark ? .gray : waterColor)
                                .opacity(waterViewOpacity)
                        }
                        //MARK: Stepper
                        HStack{
                            Stepper(onIncrement: {
                                cups += 1
                            }, onDecrement: {
                                cups -= 1
                            }, label: {Text("Cups")})
                            .labelsHidden()
                        }
                        .opacity(waterViewOpacity)
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
                                waterColor = currentWaterColor(colorScheme: colorScheme)
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
            PopUp(active: $popUp, cups: $cups, waterColor: $waterColor)
                .environmentObject(user)
                .environmentObject(userDocument)
                .font(.title)
                .clearModalBackground()
        })
        
        .sheet(isPresented: $isDiuretic, content: {
            DiureticView(popUp: $popUp, cups: $cups, isDiuretic: $isDiuretic,  customDrinkDocument: CustomDrinkViewModel(), waterColor: $waterColor)
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
        .onChange(of: self.cups, perform: { value in
            percentageWater = (100 / ((waterIntake) / Double(cupConverter())) * self.cups)
            hydration.document.uploadCups(cups: Int(cups))
            cupsLeft = (waterIntake / Double(cupConverter())) - cups
            formattedFloat = String(format: "%.1f", cupsLeft)
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
    var body: some View {
        NavigationView {
            ZStack {
                VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light)).ignoresSafeArea(.all)
                HStack{
                    Spacer()
                    Button(action: {
                        active = false
                    }, label: {
                        Text("Done")
                    }).scaleEffect(0.75)
                }
                
                VStack {
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
            }
            .sheet(isPresented: $isDiuretic, content: {
                DiureticView(popUp: $active, cups: self.$cups, isDiuretic: $isDiuretic, customDrinkDocument: CustomDrinkViewModel(), waterColor: self.$waterColor)
                    .frame( height: UIScreen.main.bounds.height / 2, alignment: .center)
                })
        }
    }
}



