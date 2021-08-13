//
//  RegisterView.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/7/21.
//

import SwiftUI
import Combine


struct RegisterView: View {
    
    @Binding var Dashboard: Bool
    @Binding var registerView: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
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
    @State private var alert: Bool = false
    @State private var isCoffeeDrinker: Bool = false
    
    @State private var fieldsWidth: CGFloat = UIScreen.main.bounds.width
    @State private var registerViewWidth: CGFloat = 0.9
    
    @AppStorage ("appleFirestoreExists") var appleFireStoreExists: Bool = false

    @AppStorage ("log_status") var appleLogStatus = false
    @AppStorage ("appleName") var appleName: String = ""
    @AppStorage ("appleEmail") var appleEmail: String = ""
    @AppStorage ("appleUID") var appleUID: String = ""

    @EnvironmentObject var userCreation: UserRepository
    
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.gray.opacity(0.4)
                VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
            }

            ScrollView() {
                ZStack{
                    Text("Register").font(.headline)
                        .bold()
                        .padding()
                }
                VStack{
                    
                    TextField("Name", text: self.$name)
                        .keyboardType(.emailAddress)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(self.name == "" ? borderColor : Color.green, lineWidth: 2)
                        )
                    TextField("Email", text: self.$email)
                        .keyboardType(.emailAddress)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(self.email == "" ? borderColor : Color.green, lineWidth: 2)
                        )
                    if !appleLogStatus {
                        SecureField("Password", text: self.$password)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(self.password == "" ? borderColor : Color.green, lineWidth: 2)
                            )
                        SecureField("Password Match", text: self.$passwordMatch)
                            .padding()
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
                    }
                    
                    HStack() {
                        Text(" ")
                        TextField("Weight", text: $weight)
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
                        Spacer()
                        
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(self.weight == "" ? borderColor : Color.green, lineWidth: 2))
                    
                }
                
                Button(action: {
                    let waterIntake = ((Double(self.weight)!) / 100) * waterIntakeCalculator()
                    
                    if appleLogStatus {
                        appleUserRegister(email: email, name: name, height: height, weight: weight, metric: metric, waterIntake: waterIntake)
                        Dashboard = true
                    } else {
                        registerUser(email: self.email, name: self.name, password: self.password, rePassword: self.passwordMatch, height: self.height, weight: self.weight, metric: self.metric, waterIntake: waterIntake )
                    }
                }, label: {
                    Text("Register")
                }).padding()
                    .buttonStyle(LoginButton())
            }
            .frame(width: fieldsWidth * registerViewWidth)
            .position(x:viewPosition(geometry: geo).width,y: viewPosition(geometry: geo).height)

        }

      
        
        .onAppear {
            if appleLogStatus {
                self.email = appleEmail
                self.name = appleName
            }
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                registerViewWidth = 0.6
            }
        }
     
            .alert(isPresented: self.$alert, content: {
                Alert(title: Text("Error"), message: Text(self.error), dismissButton: .default(Text("OK")))
            })
        
  
    }

    
    func viewPosition(geometry: GeometryProxy) -> CGSize {
        var x: CGFloat = 0
        var y: CGFloat = 0
        if UIDevice.current.userInterfaceIdiom == .phone {
            x = geometry.frame(in: .global).midX
            y = geometry.frame(in: .global).midY
            return CGSize(width: x, height: y)
        } else {
            y = geometry.frame(in: .global).midY / 2
            x = geometry.frame(in: .global).midX * 0.7
            return CGSize(width: x, height: y)
        }
    }
    func appleUserRegister(email: String, name: String, height: Double, weight: String, metric: Bool, waterIntake: Double ) {
        
        if (email != "" && name != "" && height != 0 && weight != "" ) {
            
            let weight: Double = Double(weight)!
            print("appleUID: \(appleUID)")
            UserDefaults.standard.set(appleUID, forKey: "userID")
            userCreation.addUserInformation(name: name, weight: weight, height: height, userID: appleUID, metric: metric, waterIntake: waterIntake)
            print("appleLogStatus before: \(appleLogStatus)")
            print("appleFireStoreExists before: \(appleFireStoreExists)")
            appleLogStatus = false
            appleFireStoreExists = true
            print("appleLogStatus after: \(appleLogStatus)")
            print("appleFireStoreExists after: \(appleFireStoreExists)")
        } else {
            self.borderColor = Color.red
        }
    }
    
    func registerUser(email: String, name: String, password: String, rePassword: String, height: Double, weight: String, metric: Bool, waterIntake: Double){
        
        if(email != "" && name != "" && password != "" && rePassword != "" && height != 0 && weight != "" ) {
            if(password == rePassword) {
                let weight: Double = Double(weight)!
                userCreation.signUpUser(email: email, password: password, name: name, weight: weight, height: height, metric: metric, waterIntake: waterIntake, onSucces: {
                }, onError: {error in
                    self.error = error.description
                    self.alert = true
                })
            } else {
                alert = true
                self.error = "Passwords do not match"
            }
        } else {
            self.borderColor = Color.red
        }
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




