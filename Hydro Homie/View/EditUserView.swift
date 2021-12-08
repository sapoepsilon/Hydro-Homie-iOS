//
//  EditUserView.swift
//  EditUserView
//
//  Created by Ismatulla Mansurov on 8/24/21.
//

import SwiftUI
import Combine
import FirebaseAuth
import SwiftUI
import Combine
import FirebaseAuth

struct EditUserView: View {
    
    @State private var changeEmail: String = ""
    @State private var changePassword: String = ""
    @State private var changePasswordMatch: String = ""
    @State private var changeName: String = ""
    @State private var changeHeight: Double = 0
    @State private var changeWeight: String = ""
    @State private var changeGender: String = ""
    @State private var borderColor: Color = Color.gray
    @State private var changeIsCoffeDrinker: Bool = false
    @State private var changeExerciseTimeAmount: Int = 0
    @State var waterColor: Color = Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5)
    
    //alert
    @Environment(\.colorScheme) var colorScheme
    @Binding  var backgroundColorTop: Color
    @Binding  var backgroundColorBottom: Color
    @State private var isLoad: Bool = false
    
    @State private var alertMessage: String = ""
    @State private var isAlert: Bool = false
    
    @State private var usedUID: String = ""
    @Binding var isMetric: Bool
    @Binding var isDashboard: Bool
    @State private var  isSecureField = true
    @State private var isChangePassword: Bool = false
    @State private var isChangeEmail: Bool = false
    @EnvironmentObject var user: UserDocument
    @AppStorage ("log_status") var appleLogStatus = false
    
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { geo in
                Color.gray.opacity(0.2)
                VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
            }
        
        ScrollView(.vertical, showsIndicators: false) {
            HStack {
                Spacer()
                Button(action: {
                    isDashboard = false
                }, label: {
                    Text("Cancel")
                }).padding()
            }
            ZStack{
                Text("Edit your info").font(.headline)
                    .bold()
                    .padding()
            }
            
            VStack{
                HStack {
                    Text("Change Password?")
                        .opacity(isChangeEmail ? 0 : 1)
                    Picker("Change password?", selection: $isChangePassword.animation(), content: {
                        Text("Yes") .tag(true)
                        Text("No").tag(false)
                    })
                        .fixedSize()
                        .foregroundColor(.white)
                        .pickerStyle(SegmentedPickerStyle())
                        .opacity(isChangeEmail ? 0 : 1)
                    
                }.opacity(appleLogStatus ? 0 : 1)
                
                
                if !appleLogStatus {
                    HStack {
                        Text("Change email?")
                            .opacity(isChangePassword ? 0 : 1)
                        Picker("Change email?", selection: $isChangeEmail.animation(), content: {
                            Text("Yes") .tag(true)
                            Text("No").tag(false)
                        })
                            .fixedSize()
                            .foregroundColor(.white)
                            .pickerStyle(SegmentedPickerStyle())
                            .opacity(isChangePassword ? 0 : 1)
                    }.padding()
                    
                    VStack {
                        if isChangePassword && !isChangeEmail {
                            SATextField(tag: 2, placeholder: "New password", changeHandler: {(password) in
                                self.changePassword = password
                            }, isSecureTextEntry: $isSecureField, onCommitHandler: {
                                print("commit handler")
                            })
                                .padding()
                                .fixedSize(horizontal: false, vertical: true)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(self.changePassword == "" ? borderColor : Color.green, lineWidth: 2)
                                )
                            SATextField(tag: 3, placeholder: "repeat Password", changeHandler: { (pass) in
                                self.changePasswordMatch = pass
                            }, isSecureTextEntry: $isSecureField, onCommitHandler: {
                                print("commit handler")
                            })
                                .padding()
                                .fixedSize(horizontal: false, vertical: true)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(self.changePasswordMatch == "" ? borderColor : Color.green, lineWidth: 2)
                                )
                            
                        }
                        if isChangeEmail {
                            SATextField(tag: 1, placeholder: "E-mail", changeHandler: { (email) in
                                self.changeEmail = email
                            }, onCommitHandler: {
                                print("commit handler")
                            }, text: changeEmail)   .padding()
                                .fixedSize(horizontal: false, vertical: true)
                                .keyboardType(.emailAddress)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(self.changeEmail == "" ? borderColor : Color.green, lineWidth: 2)
                                )
                        }
                    }
                }
                    VStack {
                        if !isChangeEmail && !isChangePassword {
                        SATextField(tag: 0, placeholder: "Name", changeHandler: { (name) in
                            self.changeName = name
                        }, onCommitHandler: {
                            print("commit handler")
                        }, text: changeName)
                            .padding()
                            .keyboardType(.default)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(self.changeName == "" ? borderColor : Color.green, lineWidth: 2)
                            )
                        
                        Section{
                            HStack{
                                Spacer(minLength: 15)
                                if(changeHeight == 0){
                                    Text("Height")
                                }
                                if !isMetric {
                                    Text("\(String(format: "%.1f", changeHeight)) '")
                                } else {
                                    Text("\(String(format: "%.1f", changeHeight)) cm")
                                }
                                Menu {
                                    Button(action:{
                                        if isMetric {
                                            self.changeHeight = 0.0}
                                        isMetric = false
                                    }){
                                        Text("Imperic")
                                    }
                                    Button(action:{
                                        if !isMetric{
                                            self.changeHeight = 0.0
                                        }
                                        isMetric = true
                                    }){
                                        Text("Metric").foregroundColor(.blue)
                                    }
                                } label: {
                                    if(isMetric == false){
                                        Text("Imperic")
                                            .foregroundColor(self.changeHeight == 0 ? borderColor : Color.green)
                                        Image(systemName: "ruler").foregroundColor(.blue)
                                    } else {
                                        Text("Metric ")
                                            .foregroundColor(self.changeHeight == 0 ? borderColor : Color.green)
                                        (Image(systemName: "ruler")).foregroundColor(.blue)
                                    }
                                }
                                .foregroundColor(.black)
                                HeightPicker(metric: $isMetric, height: $changeHeight)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(self.changeHeight == 0 ? borderColor : Color.green, lineWidth: 2))
                        }
                        
                        HStack() {
                            Text("")
                            TextField("Weight", text: $changeWeight)
                                .keyboardType(.numberPad)
                                .onReceive(Just(changeWeight)) { newValue in
                                    let filtered = newValue.filter { "0123456789.".contains($0) }
                                    if filtered != newValue {
                                        self.changeWeight = filtered
                                    }
                                }
                            if isMetric {
                                Text("kg")
                                    .padding()
                                    .opacity(0.6)
                            } else {
                                Text("lb")
                                    .padding()
                                    .opacity(0.6)
                            }
                            Spacer()
                            
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(self.changeWeight == "" ? borderColor : Color.green, lineWidth: 2))
                        
                        HStack {
                            Text(" ")
                            Text(String(changeExerciseTimeAmount))
                            Text("Minutes")
                                .padding()
                            Spacer()
                            workoutPicker()
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(self.changeExerciseTimeAmount == 0 ? borderColor : Color.green, lineWidth: 2))
                        HStack() {
                            Toggle("Are you a coffee Drinker? ", isOn: $changeIsCoffeDrinker)
                        }
                        }
                    }.transition(.slide)
                }
            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width * 0.6 : UIScreen.main.bounds.width * 0.9     , alignment: .center)
            //MARK: EDIT BUTTON
            Button(action: {
                var waterIntakeCalculator: Double {
                    if isMetric {
                        return 4300.5
                    } else {
                        return 67
                    }
                }
                var waterIntake = ((Double(changeWeight) ?? 0) / 100) * waterIntakeCalculator
                waterIntake += exerciseHydration()
                let weight = Double(changeWeight) ?? 0
                if isChangePassword {
                    if (changeEmail != "" && changePassword != "" && changePasswordMatch != "") {
                        if changePassword != changePasswordMatch {
                            borderColor = Color.red
                        } else {
                            isLoad = true
                            user.changeCredentials(newPassword: changePassword) { newPassword, returnMessage in
                                if newPassword {
                                    alertMessage = returnMessage
                                    isLoad = false
                                    isAlert = true
                                } else {
                                    isLoad = false
                                    alertMessage = returnMessage
                                    isAlert = true
                                }
                            }
                        }
                    }
                } else if isChangeEmail {
                    isLoad = true
                    user.changeEmail(email: changeEmail) { isEmailChanged, returnMessage in
                        if isEmailChanged {
                            isLoad = false
                            alertMessage = returnMessage
                            isAlert = true
                        } else {
                            isLoad = false
                            alertMessage = returnMessage
                            isAlert = true
                        }
                        
                    }
                } else {
                    if (changeHeight != 0 && changeWeight != "" ) {
                        alertMessage = user.changeData(userID: usedUID, name: changeName, weight: weight, height: changeHeight, isMetric: isMetric, isCoffeeDrinker: changeIsCoffeDrinker, waterIntake: waterIntake)
                        isAlert = true
                    } else {
                        self.borderColor = Color.red
                    }
                }
            }, label: {
                Text("Edit")
            }).padding()
                .buttonStyle(LoginButton())
        }
        }.clipped()
        .alert(isPresented: $isAlert, content: {
            Alert(title: Text("Alert"), message: Text(alertMessage + " Changes in your account will take 1 business day to reflect."), dismissButton: .default(Text("OK"), action: {
                withAnimation {
                    print("is Dashboard \(isDashboard)")
                    isDashboard = false
                }
            }))
        })
        .alertView(isPresented: $isLoad, overlayView: {
            LoadingView()
        })
        .onAppear(perform: {
            print("user name: \(user.user.name)")
            changeEmail = (Auth.auth().currentUser?.email) ?? ""
            changeName = self.user.user.name
            changeWeight = String(self.user.user.weight)
            changeHeight = Double(self.user.user.height)
            isMetric = self.user.user.metric
            changeIsCoffeDrinker = self.user.user.isCoffeeDrinker
            usedUID = Auth.auth().currentUser!.uid 
            print("Used id: \(usedUID)")
        })
    }
    
    func workoutPicker() -> some View {
        let workoutTime = [15,30,45,60,75,90,105,120,135,150,165,180,195,210,225, 240, 255, 270, 285, 300, 315, 330, 345, 360, 375, 390, 405, 420, 435, 450, 465, 480, 495, 510, 525, 540]
        
        return Menu("Do you workout? ") {
            ForEach(workoutTime, id: \.self) { action in
                Button(action: {
                    changeExerciseTimeAmount = action
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
    
    func background() -> some View {
        return LinearGradient(gradient: Gradient(colors: [backgroundColorTop , backgroundColorBottom]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.vertical)
    }
    
    func exerciseHydration() -> Double {
        var cupSize: Double {
            return isMetric ? 237 : 8
        }
        let cupConverter: Double = Double(changeExerciseTimeAmount / 30)
        return cupSize * cupConverter
    }
}

