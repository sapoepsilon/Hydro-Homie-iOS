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
import AuthenticationServices


struct ContentView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @StateObject var appleLoginData = UserRepository()
    @EnvironmentObject var user: UserRepository
    @Environment(\.colorScheme) var colorScheme
    @State private var signIn: Bool = UserRepository().loggedIn
    @State private var error: String = ""
    @State private var timeRemaining : Double = 0
    @State private var borderColor: Color = Color.white
    @State private var registerView: Bool = false
    @State private var waterColor: Color = Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5)
    
    
    @State  var waterBackgroundColor =  Color.clear
    @AppStorage ("log_status") var appleLogStatus = false
    @AppStorage ("appleFirestoreExists") var appleFireStoreExists: Bool = false
    @AppStorage ("appleName") var appleName: String = ""
    @State private var backgroundColorTop: Color = Color(red: 148/255, green: 189/255, blue: 227/255, opacity: 89/100)
    @State private var backgroundColorBottom: Color = Color(red: 197/255, green: 197/255, blue: 237/255, opacity: 93/100)
    
    
    
    let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()
    
    
    
    var body: some View {
        GeometryReader { geomtry in
            if(user.loggedIn == false) {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [backgroundColorTop , backgroundColorBottom]), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.vertical)
                    VStack(spacing: 5) {
                            Text("Hydro Homie")
                                .foregroundColor(waterColor)
                                .font(.system(size: geomtry.size.height * 0.09))
                            WaterView(factor: self.$timeRemaining, waterColor: self.$waterColor, backgroundColor: $waterBackgroundColor)
                                .shadow(color: colorScheme == .light ? Color.black : Color.gray , radius: 6)
                                .frame( height: UIScreen.main.bounds.height * 0.4, alignment: .center)
                        
                        Spacer().frame(height: UIScreen.main.bounds.height * 0.005)

                            TextField("Username", text: self.$email)
                                .padding(.horizontal, 10)
                                .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.07, alignment: .center)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(self.email == "" ? borderColor : Color.green, lineWidth: 2)
                                )
                                .foregroundColor(colorScheme == .light ? .white : .gray)


                            SecureField("Password", text: self.$password)
                                .padding(.horizontal, 10)
                                .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.07, alignment: .center)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(self.password == "" ? borderColor : Color.green, lineWidth: 2))
                                .foregroundColor(colorScheme == .light ? .white : .gray)

                            Button(action: {
                                user.signInUser( email: email, password: password, onSucces: {
                                }, onError: {error in
                                    self.signIn = true
                                    self.error = error.description })
                            }, label: {
                                Text("Sign In")
                            }).alert(isPresented: self.$signIn, content: {
                                Alert(title: Text("error"), message: Text(error.description), dismissButton: .default(Text("OK")))
                            })                                    .buttonStyle(LoginButton())
                            
                            //MARK: Sign-in with Apple ID
                            
                            SignInWithAppleButton(
                                onRequest: { request in
                                    appleLoginData.nonce = randomNonceString()
                                    request.requestedScopes = [.email, .fullName]
                                    request.nonce = sha256(appleLoginData.nonce)
                                    
                                    
                                },
                                onCompletion: { result in
                                    
                                    switch result {
                                    case .success(let user):
                                        guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                                            return
                                        }
                                        appleName = credential.fullName?.givenName ?? "Please enter your name"
                                        appleLoginData.appleAuthenticate(credintial: credential)
                                        if appleLogStatus {
                                            if !appleFireStoreExists {
                                                registerView = true
                                            }
                                        }
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    }
                                }
                            )
                            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                            .frame(width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.height * 0.05)
                                                                .clipShape(Capsule())
                            //                                    .padding(.horizontal, 30)
                            
                            Button(action: {
                                
                                registerView = true
                            }, label: {
                                Text("Do not have an account? ")
                            })
                            
                        
                    }
                    
                    .onAppear {
                        if colorScheme == .dark {
                            backgroundColorTop = Color(red: 63/255, green: 101/255, blue: 131/255, opacity: 51/100)
                            backgroundColorBottom = Color(red: 115/255, green: 116/255, blue: 117/255, opacity: 46/100)
                        }
                        
                    }
                }
            } else {
                Dashboard(userDocument: UserDocument(), backgroundColorTop: $backgroundColorTop, backgroundColorBottom: $backgroundColorBottom)
                    .environmentObject(HydrationDocument())
            }
            
        }

        
        
        .sheet(isPresented: self.$registerView, content: {
            RegisterView(Dashboard: $user.loggedIn, registerView: self.$registerView)
                .environmentObject(UserRepository())
                .clearModalBackground()
                .edgesIgnoringSafeArea(.bottom)
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
        
        .onAppear{      
            if colorScheme == .dark {
                waterColor = Color( red: 0, green: 0.5, blue: 0.7, opacity: 0.5)
                borderColor = Color.white
                
            } else {
                waterColor = Color( red: 0, green: 0.5, blue: 0.8, opacity: 0.5)
                borderColor = Color.white
            }
            if appleLogStatus {
                if appleFireStoreExists {
                    user.checkUser()
                }
            } else {
                user.checkUser()
            }
        }
    }
}
