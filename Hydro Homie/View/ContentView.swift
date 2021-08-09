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
import FirebaseAuth
import CryptoKit
import AuthenticationServices

struct ContentView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var user: UserRepository
    @Environment(\.colorScheme) var colorScheme
    @State private var signIn: Bool = UserRepository().loggedIn
    @State private var error: String = ""
    @State private var timeRemaining : Double = 0
    @State private var borderColor: Color = Color.white
    @State private var registerView: Bool = false
    @State private var waterColor: Color = Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5)

    @State  var waterBackgroundColor =  Color.clear
    
    @State private var backgroundColorTop: Color = Color(red: 148/255, green: 189/255, blue: 227/255, opacity: 89/100)
    @State private var backgroundColorBottom: Color = Color(red: 197/255, green: 197/255, blue: 237/255, opacity: 93/100)


    
    let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()

    //MARK: Sign-in with Apple ID
    
    
    @State var currentNonce:String?
       
       //Hashing function using CryptoKit
       func sha256(_ input: String) -> String {
           let inputData = Data(input.utf8)
           let hashedData = SHA256.hash(data: inputData)
           let hashString = hashedData.compactMap {
           return String(format: "%02x", $0)
           }.joined()

           return hashString
       }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    var body: some View {

        GeometryReader { geomtry in
            VStack{
                if(user.loggedIn == false) {
                    ZStack {
                        
                        LinearGradient(gradient: Gradient(colors: [backgroundColorTop , backgroundColorBottom]), startPoint: .top, endPoint: .bottom)
                                   .edgesIgnoringSafeArea(.vertical)
                        VStack{
                            Text("Hydro Homie")
                                .font(.system(size: geomtry.size.height * 0.09))
                                .foregroundColor(waterColor)
                            VStack{
                                WaterView(factor: self.$timeRemaining, waterColor: self.$waterColor, backgroundColor: $waterBackgroundColor)
                                    .shadow(color: colorScheme == .light ? Color.black : Color.gray , radius: 6)
                                    .frame( height: geomtry.size.height * 0.4, alignment: .center)
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
                                    .foregroundColor(colorScheme == .light ? .white : .gray)
                                    .padding(.horizontal, 30)
                                    
                                SecureField("Password", text: self.$password)
                                    .padding()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(self.password == "" ? borderColor : Color.green, lineWidth: 2))
                                    .padding(.horizontal, 30)
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
                                })
                                .buttonStyle(LoginButton())
                                    
                                Button(action: {
                                    registerView = true
                                }, label: {
                                    Text("Do not have an account? ")
                                })
                                }
                            }
                        }
                    }
                    .onAppear {
                        if colorScheme == .dark {
                            backgroundColorTop = Color(red: 63/255, green: 101/255, blue: 131/255, opacity: 51/100)
                            backgroundColorBottom = Color(red: 115/255, green: 116/255, blue: 117/255, opacity: 46/100)
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
        }
        .onAppear{
            if colorScheme == .dark {
                
                waterColor = Color( red: 0, green: 0.5, blue: 0.7, opacity: 0.5)
                borderColor = Color.white
                
            } else {
                waterColor = Color( red: 0, green: 0.5, blue: 0.8, opacity: 0.5)
                borderColor = Color.white
                }
            user.checkUser()
            
        }
    }
}
