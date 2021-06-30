//
//  ContentView.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 4/26/21.
//

import SwiftUI
import Firebase
import Combine
import CoreData
import CoreLocation

struct ContentView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var user: UserRepository
    @Environment(\.colorScheme) var colorScheme
    @State private var signIn: Bool = UserRepository().loggedIn
    @State private var error: String = ""
    @State private var timeRemaining : Double = 0
    @State private var borderColor: Color = Color.gray
    @State private var registerView: Bool = false
    @State private var waterColor: Color = Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5)
    
    let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()

    var body: some View {

        GeometryReader { geomtry in
            VStack{
                if(user.loggedIn == false) {
                    VStack{
                        Text("Hydro Homie")
                            .font(.system(size: geomtry.size.height * 0.09))
                            .foregroundColor(Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5))
                        VStack{
                            WaterView(factor: self.$timeRemaining, waterColor: self.$waterColor)
                             
                        }
                        .frame( height: geomtry.size
                                    .height * 0.4, alignment: .center)
                        .padding()
                        VStack(alignment: .leading){
                            VStack(){
                            TextField("Username", text: self.$email)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(self.email == "" ? borderColor : Color.green, lineWidth: 2)
                                )
                                .padding(.horizontal, 10)
                            SecureField("Password", text: self.$password)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(self.password == "" ? borderColor : Color.green, lineWidth: 2))
                                .padding(.horizontal, 10)
                            Button(action: {
                                user.signInUser( email: email, password: password, onSucces: {
                                }, onError: {error in
                                    self.signIn = true
                                    self.error = error.description })
                            }, label: {
                                Text("Sign In")
                                    .foregroundColor(Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5))
                            }).alert(isPresented: self.$signIn, content: {
                                Alert(title: Text("error"), message: Text(error.description), dismissButton: .default(Text("OK")))
                            })
                            Button(action: {
                                registerView = true
                            }, label: {
                                Text("Do not have an account? ")
                            })
                            }
                        }.frame(width: geomtry.size.width , height: geomtry.size.height / 2, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    }
                } else {
                    Dashboard(userDocument: UserDocument())
                        .environmentObject(HydrationDocument())
                }
            }.sheet(isPresented: self.$registerView, content: {
                RegisterView(Dashboard: $user.loggedIn, registerView: self.$registerView)
                    .environmentObject(UserRepository())
            })
            .onChange(of: user.loggedIn, perform: {newValue in
                print("signIn \(signIn)")
                    self.registerView = false
            })
            .onReceive(timer, perform: { _ in
                if self.timeRemaining < 100 {
                    self.timeRemaining += 0.1
                }
            })
        }
        .onAppear{
            if colorScheme == .dark {
                    waterColor = Color( red: 0, green: 0.5, blue: 0.7, opacity: 0.5)
                } else {
                    waterColor = Color( red: 0, green: 0.5, blue: 0.8, opacity: 0.5)
                }
            user.checkUser()
        }
    }
}
