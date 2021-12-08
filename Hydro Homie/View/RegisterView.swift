//
//  RegisterView.swift
//  Hydro Comrade
//
//  Created by Ismatulla Mansurov on 6/7/21.
//

import SwiftUI
import Combine
import Firebase


enum newAlert: String, Identifiable {
    var id: String {
        rawValue
    }
    case isError
    case isCoffee
}
struct RegisterView: View {
    @State private var isError: Bool = false
    @Binding var isUserExist: Bool
    @State var onCompleteBlock: (() -> Void)
    @Binding var isLoad: Bool
    @Binding var Dashboard: Bool
    @Binding var registerView: Bool
    @State var alert: newAlert?
    @Environment(\.colorScheme) var colorScheme
    @State private var barColor: Color = Color.black
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordMatch: String = ""
    @State private var name: String = ""
    @State private var height: Double = 0
    @State private var weight: String = ""
    @State private var gender: String = ""
    @State private var borderColor: Color = Color.gray
    @State private var metric: Bool = false
    @State private var error: String = ""
    //    @State private var alert: Bool = false
    @State private var isCoffeeDrinker: Bool = false
    @State private var exerciseTimeAmount: Int = 0
    @State private var isWorkoutActive: Bool = false
    @State private var weigthConverter: CGFloat = 30
    @State private var isCoffeeMessage: Bool = false
    
    @State private var fieldsWidth: CGFloat = UIScreen.main.bounds.width
    @State private var registerViewWidth: CGFloat = 0.9
    
    @State var fieldFocus = [false, true, false, false]
    @State private var  isSecureField = true
    @State private var isSecureReField = true
    
    @AppStorage ("appleFirestoreExists") var appleFireStoreExists: Bool = false
    
    @AppStorage ("log_status") var appleLogStatus = false
    @AppStorage ("appleName") var appleName: String = ""
    @AppStorage ("appleEmail") var appleEmail: String = ""
    @AppStorage ("appleUID") var appleUID: String = ""
    
    @State private var scrollValue: Int = 3
    
    @EnvironmentObject var userCreation: UserRepository
    var isZoomed: Bool {
        return UIScreen.main.scale < UIScreen.main.nativeScale
    }
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            ZStack(alignment: .top) {
                GeometryReader { geo in
                    Color.gray.opacity(0.2)
                    VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
                
                }
                VStack {
                    Text("Register")
                        .font(.headline)
                        .bold()
                        .padding()
                    
                    if isUserExist {
                        Text("Looks like we are missing some of essential data, so the app works properlt. Please fill these fields up!")
                    }
                    
                    SATextField(tag: 0, placeholder: "Name", changeHandler: { (name) in
                        self.name = name
                    }, onCommitHandler: {
                        print("commit handler")
                    }, text: self.name)
                        .onTapGesture {
                            self.name = ""
                        }
                        .padding()
                        .keyboardType(.default)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(self.name == "" ? borderColor : Color.green, lineWidth: 2)
                        )                                    .fixedSize(horizontal: false, vertical: true)
                    
                    
                    
                    if !isUserExist {
                    SATextField(tag: 1, placeholder: "E-mail", changeHandler: { (email) in
                        self.email = email
                    }, onCommitHandler: {
                        print("commit handler")
                    }, text: self.email)   .padding()
                        .fixedSize(horizontal: false, vertical: true)
                        .keyboardType(.emailAddress)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(self.email == "" ? borderColor : Color.green, lineWidth: 2)
                        )
                    }
                    if !appleLogStatus && !isUserExist {
                        SATextField(tag: 2, placeholder: "Password", changeHandler: {(password) in
                            self.password = password
                        }, isSecureTextEntry: $isSecureField, onCommitHandler: {
                            print("commit handler")
                        })
                            .padding()
                            .fixedSize(horizontal: false, vertical: true)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(self.password == "" ? borderColor : Color.green, lineWidth: 2)
                            )
                        
                        SATextField(tag: 3, placeholder: "Re-type password", changeHandler: { (pass) in
                            self.passwordMatch = pass
                        }, isSecureTextEntry: $isSecureReField, onCommitHandler: {
                            print("commit handler")
                        })
                            .padding()
                            .fixedSize(horizontal: false, vertical: true)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(self.passwordMatch == "" ? borderColor : Color.green, lineWidth: 2)
                            )
                    }
                    Section{
                        HStack{
                            Spacer(minLength: 15)
                            if(height == 0){
                                Text("Height").foregroundColor(.gray).opacity(0.6)
                            }
                            if !metric {
                                Text("\(String(format: "%.1f", height)) '")
                            } else {
                                Text("\(String(format: "%.1f", height)) cm")
                            }
                            Menu {
                                Button(action:{
                                    if metric {
                                        self.height = 0.0}
                                    metric = false
                                }){
                                    Text("Imperic")
                                }
                                Button(action:{
                                    if !metric{
                                        self.height = 0.0}
                                    metric = true
                                }){
                                    Text("Metric").foregroundColor(.blue)
                                }
                            } label: {
                                if(metric == false){
                                    Text("Imperic")
                                        .foregroundColor(self.height == 0 ? borderColor : Color.green)
                                    Image(systemName: "ruler").foregroundColor(.blue)
                                    
                                } else {
                                    Text("Metric ")
                                        .foregroundColor(self.height == 0 ? borderColor : Color.green)
                                    (Image(systemName: "ruler")).foregroundColor(.blue)
                                }
                            }
                            .foregroundColor(.black)
                            HeightPicker(metric: $metric, height: $height)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(self.height == 0 ? borderColor : Color.green, lineWidth: 2))
                    }                        .fixedSize(horizontal: false, vertical: true)
                    
                    
                    HStack() {
                        Text(" ")
                        SATextField(tag: 4, placeholder: "Weight", changeHandler: { (weight) in
                            self.weight = weight
                        }, returnKeyType: UIReturnKeyType.done, onCommitHandler: {
                            print("weight")
                        }, text: self.weight)
                            .fixedSize(horizontal: false, vertical: true)
                            .keyboardType(.numberPad)
                            .onReceive(Just(weight)) { newValue in
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                if filtered != newValue {
                                    self.weight = filtered
                                }
                            }
                        if metric {
                            Text("kg")
                                .foregroundColor(.gray)
                                .padding()
                                .opacity(0.6)
                        } else {
                            Text("lb")
                                .foregroundColor(.gray)
                                .padding()
                                .opacity(0.6)
                        }
                    }                        .fixedSize(horizontal: false, vertical: true)
                    
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(self.weight == "" ? borderColor : Color.green, lineWidth: 2))
                    HStack {
                        VStack {
                            Toggle("Do You Workout?", isOn: $isWorkoutActive).padding()
                            if isWorkoutActive {
                                workoutPicker()
                            }
                        }
                    }                         .fixedSize(horizontal: false, vertical: true)
                    
                    
                    HStack {
                    HStack() {
                        Toggle("Are you a coffee Drinker? ", isOn: $isCoffeeDrinker)
                        //                            .foregroundColor(.gray)
                            .padding()
                  
                    }
                        Button(action: {
                            isCoffeeMessage = true

                        }, label: {
                            Text("Tell me more")
                        })
                           
                    }
                    
                    
                    
                    
                    Button(action: {
                        isLoad = true
                        var waterIntake = ((Double(self.weight) ?? 0) / 100) * waterIntakeCalculator()
                        waterIntake += exerciseHydration()
                        if appleLogStatus {
                            if (email != "" && name != "" && height != 0 && weight != "" ) {
                                appleUserRegister(email: email, name: name, height: height, weight: weight, metric: metric, isCoffeeDrinker: isCoffeeDrinker, waterIntake: waterIntake)
                                Dashboard = true
                            } else {
                                self.borderColor = Color.red
                            }
                        } else if isUserExist {
                            if(name != "" && height != 0 && weight != "") {
                                let weight: Double = Double(weight)!
                                userCreation.addUserInformation(name: name, weight: weight, height: height, userID: Auth.auth().currentUser!.uid , metric: metric, isCoffeeDrinker: isCoffeeDrinker, waterIntake: waterIntake, completionHandler: {isReady in
                                    if isReady {
                                        onCompleteBlock()
                                    }
                                })
                            } else {
                                self.borderColor = Color.red
                            }
                        }
                        else {
                            if(email != "" && name != "" && password != "" && passwordMatch != "" && height != 0 && weight != "" ) {
                                if(password == passwordMatch) {
                                    registerUser(email: self.email, name: self.name, password: self.password, rePassword: self.passwordMatch, height: self.height, weight: self.weight, metric: self.metric, isCoffeeDrinker: self.isCoffeeDrinker, waterIntake: waterIntake )
                                } else {
                                    isError = true
                                    self.error = "Passwords do not match"
                                }
                            } else {
                                self.borderColor = Color.red
                            }
                        }
                    }, label: {
                        Text("Register")
                    }).padding()
                        .buttonStyle(LoginButton())
                    
                }.frame(width: UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width * 0.6 : UIScreen.main.bounds.width * 0.9     , alignment: .center)
                    .padding(.horizontal)
            }
        } .clipped()

        
        
        
        
        .onAppear {
            if appleLogStatus {
                self.email = appleEmail
                self.name = appleName
            }
            if colorScheme == .dark {
                barColor = Color.white
            }
            if UIDevice.current.userInterfaceIdiom == .pad {
                registerViewWidth = 0.6
            }
        }
        .alertView(isPresented: $isError,blurRadius:15, overlayView: {
            VStack {
                Text(self.error).padding()
                Button(action: {
                    isError = false
                }, label: {
                    Text("Ok").fontWeight(.bold)
                }).padding()
        }
        })
        .alertView(isPresented: $isCoffeeMessage, blurRadius:15, overlayView: {
            VStack {
                Text("Do you consume 2 or more cups of coffeinated drinks per day?").padding()
                Button(action: {
                    isCoffeeMessage = false
                }, label: {
                    Text("Ok").fontWeight(.bold)
                }).padding()
        }
        })
   
        
        
    }
    
    func exerciseHydration() -> Double {
        var cupSize: Double {
            return metric ? 237 : 8
        }
        let cupConverter: Double = Double(exerciseTimeAmount / 30)
        return cupSize * cupConverter
    }
    
    func workoutPicker() -> some View {
        let workoutTime = [15,30,45,60,75,90,105,120,135,150,165,180,195,210,225, 240, 255, 270, 285, 300, 315, 330, 345, 360, 375, 390, 405, 420, 435, 450, 465, 480, 495, 510, 525, 540]
        
        
        return Menu( exerciseTimeAmount == 0 ? "How much do you workout a day?" : "\(exerciseTimeAmount) minutes") {
            ForEach(workoutTime, id: \.self) { action in
                Button(action: {
                    exerciseTimeAmount = action
                }, label: {
                    if action % 60 == 0 {
                        Text("\(action / 60) hour")
                    } else {
                        if getTheMinutes(value: action, divider: 60).0 != 0 {
                            Text("\(String(format: "%0.f", getTheMinutes(value: action, divider: 60).0)) hour \(String(format: "%0.f", getTheMinutes(value: action, divider: 60).1)) minutes")
                        } else if getTheMinutes(value: action, divider: 60).0 == 0 {
                            Text("\(String(format: "%0.f", getTheMinutes(value: action, divider: 60).1)) minutes")
                        }
                    }
                })
            }
        }.padding()
    }
    
    func getTheMinutes(value: Int, divider: Int) -> (Double,Double) {
        let returnValue = Double(value) / Double(divider)
        var hour: Double = 0
        var minute: Double = 0
        if returnValue < 1 {
            hour = 0
            minute = (returnValue * 60.0)
        } else {
            let remainder: Double = Double(value % divider)
            hour = returnValue - (remainder / 60)
            minute = remainder
        }
        return (hour,minute)
    }
    
    func appleUserRegister(email: String, name: String, height: Double, weight: String, metric: Bool, isCoffeeDrinker: Bool, waterIntake: Double ) {
        let weight: Double = Double(weight)!
        print("appleUID: \(appleUID)")
        UserDefaults.standard.set(appleUID, forKey: "userID")
        userCreation.addUserInformation(name: name, weight: weight, height: height, userID: appleUID, metric: metric, isCoffeeDrinker: isCoffeeDrinker, waterIntake: waterIntake, completionHandler: { isReady in
            if isReady {
                onCompleteBlock()
            }
        })
    }
    
    func registerUser(email: String, name: String, password: String, rePassword: String, height: Double, weight: String, metric: Bool,isCoffeeDrinker: Bool, waterIntake: Double){
        let weight: Double = Double(weight)!
        userCreation.signUpUser(email: email, password: password, name: name, weight: weight, height: height, metric: metric, isCoffeeDrinker: isCoffeeDrinker, waterIntake: waterIntake, onSucces: { isRegistered, errorMessage in
            if isRegistered {
                onCompleteBlock()
            } else {
                error = errorMessage
                isError = true
            }
        })
    }
    
    func waterIntakeCalculator() -> Double {
        var waterIntakeCalculator: Double = 0
        if metric {
            waterIntakeCalculator = 4300.5
        } else {
            waterIntakeCalculator = 67
        }
        return waterIntakeCalculator
    }
}




