//
//  ContentView.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 4/26/21.
//

import SwiftUI
import Firebase
import Combine

struct ContentView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var user: UserRepository
    @State private var signIn: Bool
    @State private var error: String = ""
    @State private var timeRemaining : Double = 0
    @State private var borderColor: Color = Color.gray
    @State private var registerView: Bool = false
    
    let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    
    init() {
        self.signIn = UserRepository().loggedIn
    }
    var body: some View {
        
        GeometryReader { geomtry in
            VStack{
                if(user.loggedIn == false) {
                    VStack{
                        Text("Hydro Homie")
                            .font(.system(size: geomtry.size.height * 0.09))
                            .foregroundColor(Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5))
                        VStack{
                            WaterView(factor: self.$timeRemaining)}
                        .frame( height: geomtry.size
                                    .height * 0.4, alignment: .center)
                        .onReceive(timer) { time in
                            if self.timeRemaining < 100 {
                                self.timeRemaining += 1
                            }
                        }
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
                    Dashboard(userDocument: UserDocument()).environmentObject(HydrationDocument())
                }
            }.sheet(isPresented: self.$registerView, content: {
                RegisterView(Dashboard: $user.loggedIn, registerView: self.$registerView)
                    .environmentObject(UserRepository())
            })
            .onChange(of: user.loggedIn, perform: {newValue in
                print("signIn \(signIn)")
                    self.registerView = false
            })

        }

        .onAppear{
            user.checkUser()
        }
    }
}
