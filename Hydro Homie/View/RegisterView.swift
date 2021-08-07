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


    
    @EnvironmentObject var userCreation: UserRepository
    
    
    var body: some View {
        VStack(spacing:0) {
            ZStack{
                Text("Register").font(.headline)
                    .bold()
                    .padding()
                HStack{
                    Spacer()
                    Button(action: {
                        let waterIntake = ((Double(self.weight)!) / 100) * waterIntakeCalculator()
                        registerUser(email: self.email, name: self.name, password: self.password, rePassword: self.passwordMatch, height: self.height, weight: self.weight, metric: self.metric, waterIntake: waterIntake )
                    }, label: {
                        Text("Next")
                    }).padding()
                }
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
                GeometryReader{ geo in
                    HStack() {
                        Text(" ")
                        TextField("Weight", text: $weight)
                            .keyboardType(.numberPad)
                            .onReceive(Just(weight)) { newValue in
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                if filtered != newValue {
                                    self.weight = filtered
                                }
                            }.frame(width: geo.size.width / 6, alignment: .leading)
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
            }.padding(.horizontal)
            Spacer()
        }.alert(isPresented: self.$alert, content: {
            Alert(title: Text("Error"), message: Text(self.error), dismissButton: .default(Text("OK")))
        })
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




