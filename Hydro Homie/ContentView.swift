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
    @State private var timeRemaining = 0
    @State private var borderColor: Color = Color.gray
    
    let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    
    init() {
        self.signIn = UserRepository().loggedIn
    }
    
    var body: some View {
        
            
        GeometryReader { geomtry in
            if(user.loggedIn == false) {

            VStack{
                Text("Hydro Homie")
                    .font(.system(size: geomtry.size.height * 0.09))
                    .foregroundColor(Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5))
                
                VStack{
                    WaterView(percent: self.timeRemaining)
                }
                .frame( height: geomtry.size
                            .height * 0.4, alignment: .center)
                .onReceive(timer) { time in
                    if self.timeRemaining < 100 {
                        self.timeRemaining += 1
                    }
                }
                .padding()
                    
                    VStack{
                        TextField("Username", text: self.$email)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(self.email == "" ? borderColor : Color.green, lineWidth: 2)
                            )
                            .padding()
                        SecureField("Password", text: self.$password)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(self.password == "" ? borderColor : Color.green, lineWidth: 2)
                            )
                            .padding()
                        
                        Button(action: {
                            
                            user.signInUser(email: email, password: password, onSucces: {
                            }, onError: {error in
                                self.signIn = true
                                self.error = error.description
                            })
                            
                        }, label: {
                            Text("Sign In")
                                .foregroundColor(Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5))
                        }).alert(isPresented: self.$signIn, content: {
                            Alert(title: Text("error"), message: Text(error.description), dismissButton: .default(Text("OK")))
                        })
                        
                    }.frame(width: geomtry.size.width , height: geomtry.size.height / 2, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                }
                } else {
                    Dashboard()
              
            }
            
        }
        .onAppear{
            user.checkUser()
        }
        
    }
    
    
    
}
