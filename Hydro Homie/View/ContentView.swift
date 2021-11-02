//
//  ContentView.swift
//  Hydro Comrade
//
//  Created by Ismatulla Mansurov on 4/26/21.
//

import SwiftUI
import Firebase
import Combine
import CoreData
import CoreLocation
import AuthenticationServices

enum ContentSheet: String, Identifiable {
    var id:String {
        rawValue
    }
    
    case isPasswordReset
    case isRegister
}
struct ContentView: View {
    @AppStorage("welcomePage") var isWelcomePageShown: Bool = UserDefaults.standard.isWelcomePageShown
    @State var activeSheet: ContentSheet?
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var user: UserRepository
    @State private var colorScheme: ColorScheme = .light
    @State private var signIn: Bool = UserRepository().loggedIn
    @State private var error: String = ""
    @State private var timeRemaining : Double = 0
    @State private var borderColor: Color = Color.white
    @State private var registerView: Bool = false
    @State private var waterColor: Color = Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5)
    @State private var isSecureField: Bool = true
    @State private var isSignInFalse: Bool = false
    @Environment(\.colorScheme) var ColorScheme
    @State  var waterBackgroundColor =  Color.clear
    @AppStorage ("log_status") var appleLogStatus = false
    @AppStorage ("appleFirestoreExists") var appleFireStoreExists: Bool = false
    @AppStorage ("appleName") var appleName: String = ""
    @State private var backgroundColorTop: Color = Color(red: 148/255, green: 189/255, blue: 227/255, opacity: 89/100)
    @State private var backgroundColorBottom: Color = Color(red: 197/255, green: 197/255, blue: 237/255, opacity: 93/100)
    @State private var resetPasswordView: Bool = false
    @State private var isLoadingView: Bool = false
    @State private var isAppleSignInComplete: Bool = false
    @State private var appleSingInErrorDescription: String = ""
    @State private var isLoad: Bool = false
    let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()
    var isZoomed: Bool {
          return UIScreen.main.scale < UIScreen.main.nativeScale
      }
    var body: some View {
       
            ZStack {
                LinearGradient(gradient: Gradient(colors: [backgroundColorTop , backgroundColorBottom]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                if !isWelcomePageShown {
                    OnboardScreen(backgroundColorTop: $backgroundColorTop, backgroundColorBottom: $backgroundColorBottom)
                } else {
                    if !user.loggedIn{
                        if isZoomed {
                        VStack {
                            Text("Hydro Comrade")
                                .foregroundColor(waterColor)
                                .font(.title)
                            WaterView(factor: self.$timeRemaining, waterColor: self.$waterColor, backgroundColor: $waterBackgroundColor)
                                .shadow(color: colorScheme == .light ? Color.black : Color.gray , radius: 6)
                                .frame( height: UIScreen.main.bounds.height * 0.4, alignment: .center)
                            
                            Spacer().frame(height: UIScreen.main.bounds.height * 0.03)
                            
                            SATextField(tag: 0, placeholder: "E-mail", changeHandler: {(email) in
                                self.email = email
                            }, returnKeyType: .next,onCommitHandler: {
                                print("commit handler")
                            })
                                .padding()
                                .fixedSize(horizontal: false, vertical: true)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(self.email == "" ? borderColor : Color.green, lineWidth: 2)
                                )
                                .foregroundColor(colorScheme == .light ? .white : .gray)
                                .keyboardType(.emailAddress)
                                .padding(.horizontal, UIScreen.main.bounds.size.width * 0.1)
                            
                            SATextField(tag: 1, placeholder: "Password", changeHandler: {(pass) in
                                self.password = pass
                            }, returnKeyType: .done, isSecureTextEntry: $isSecureField, onCommitHandler: {
                                print("commit handler")
                            })
                                .padding()
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(colorScheme == .light ? .white : .gray)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(self.password == "" ? borderColor : Color.green, lineWidth: 2))
                                .padding(.horizontal, UIScreen.main.bounds.size.width * 0.1)
                            
                            VStack(spacing: 4) {
                                Button(action: {
                                    isLoad = true
                                    user.signInUser( email: email, password: password) { isLogged, error in
                                        if isLogged {
                                            isLoad = false
                                            
                                        } else {
                                            isLoad = false
                                            self.isSignInFalse = true
                                            self.error = error
                                            print("signin False \(isSignInFalse )")
                                        }
                                    }
                                }, label: {
                                    Text("Sign In")
                                })
                                    .buttonStyle(LoginButton())
                                
                                //                            Spacer().frame(height: UIScreen.main.bounds.height / 20)
                                //MARK: Sign-in with Apple ID
                                SignInWithAppleButton(
                                    onRequest: { request in
                                        user.nonce = randomNonceString()
                                        request.requestedScopes = [.email, .fullName]
                                        request.nonce = sha256(user.nonce)
                                    },
                                    onCompletion: { result in
                                        
                                        switch result {
                                        case .success(let user):
                                            self.user.isUploadFinished = false
                                            isLoadingView = true
                                            guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                                                return
                                            }
                                            appleName = credential.fullName?.givenName ?? "Please enter your name"
                                            self.user.appleAuthenticate(credintial: credential) { b in
                                                isLoadingView = false
                                                if b == true {
                                                    activeSheet = nil
                                                } else {
                                                    activeSheet = .isRegister
                                                }
                                            }
                                        case .failure(let error):
                                            print(error.localizedDescription)
                                            isAppleSignInComplete = true
                                            appleSingInErrorDescription = error.localizedDescription
                                            
                                        }
                                    }
                                )
                                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                                    .frame(width: 375, height: UIScreen.main.bounds.height * 0.05)
                                    .clipShape(Capsule())
                            }
                            Button(action: {
                                activeSheet = .isRegister
                            }, label: {
                                Text("Do not have an account? ")
                            })
                                .frame(width: 375, height: UIScreen.main.bounds.height * 0.05)
                                .clipShape(Capsule())
                            
                            Button(action: {
                                activeSheet = .isPasswordReset
                            }, label: {
                                Text("Reset your password")
                            })
                            //                                    .padding(.horizontal, 30)
                        }.frame( alignment: .center)
                            .onAppear {
                                if colorScheme == .dark {
                                    backgroundColorTop = Color(red: 63/255, green: 101/255, blue: 131/255, opacity: 51/100)
                                    backgroundColorBottom = Color(red: 115/255, green: 116/255, blue: 117/255, opacity: 46/100)
                                } else {
                                    backgroundColorTop = Color(red: 148/255, green: 189/255, blue: 227/255, opacity: 89/100)
                                                            backgroundColorBottom = Color(red: 197/255, green: 197/255, blue: 237/255, opacity: 93/100)
                                                            }
                            
                                                        }
                        } else {
                            GeometryReader { geomtry in
                                                     ZStack {
                                                     ScrollView() {
                                                         Text("Hydro Comrade")
                                                             .foregroundColor(waterColor)
                                                             .font(.title)
                                                         WaterView(factor: self.$timeRemaining, waterColor: self.$waterColor, backgroundColor: $waterBackgroundColor)
                                                             .shadow(color: colorScheme == .light ? Color.black : Color.gray , radius: 6)
                                                             .frame( height: UIScreen.main.bounds.height * 0.4, alignment: .center)
                         
                                                         Spacer().frame(height: UIScreen.main.bounds.height * 0.03)
                         
                                                         SATextField(tag: 0, placeholder: "E-mail", changeHandler: {(email) in
                                                             self.email = email
                                                         }, returnKeyType: .next,onCommitHandler: {
                                                             print("commit handler")
                                                         })
                                                             .padding()
                                                             .fixedSize(horizontal: false, vertical: true)
                                                             .overlay(
                                                                 RoundedRectangle(cornerRadius: 16)
                                                                     .stroke(self.email == "" ? borderColor : Color.green, lineWidth: 2)
                                                             )
                                                             .foregroundColor(colorScheme == .light ? .white : .gray)
                                                             .keyboardType(.emailAddress)
                                                             .padding(.horizontal, UIScreen.main.bounds.size.width * 0.1)
                         
                                                         SATextField(tag: 1, placeholder: "Password", changeHandler: {(pass) in
                                                             self.password = pass
                                                         }, returnKeyType: .done, isSecureTextEntry: $isSecureField, onCommitHandler: {
                                                             print("commit handler")
                                                         })
                                                             .padding()
                                                             .fixedSize(horizontal: false, vertical: true)
                                                             .foregroundColor(colorScheme == .light ? .white : .gray)
                                                             .overlay(
                                                                 RoundedRectangle(cornerRadius: 16)
                                                                     .stroke(self.password == "" ? borderColor : Color.green, lineWidth: 2))
                                                             .padding(.horizontal, UIScreen.main.bounds.size.width * 0.1)
                         
                                                         VStack(spacing: 4) {
                                                             Button(action: {
                                                                 isLoad = true
                                                                 user.signInUser( email: email, password: password) { isLogged, error in
                                                                     if isLogged {
                                                                         isLoad = false
                         
                                                                     } else {
                                                                         isLoad = false
                                                                         self.isSignInFalse = true
                                                                         self.error = error
                                                                         print("signin False \(isSignInFalse )")
                                                                     }
                                                                 }
                                                             }, label: {
                                                                 Text("Sign In")
                                                             })
                                                                 .buttonStyle(LoginButton())
                         
                                                             //                            Spacer().frame(height: UIScreen.main.bounds.height / 20)
                                                             //MARK: Sign-in with Apple ID
                                                             SignInWithAppleButton(
                                                                 onRequest: { request in
                                                                     user.nonce = randomNonceString()
                                                                     request.requestedScopes = [.email, .fullName]
                                                                     request.nonce = sha256(user.nonce)
                                                                 },
                                                                 onCompletion: { result in
                         
                                                                     switch result {
                                                                     case .success(let user):
                                                                         self.user.isUploadFinished = false
                                                                         isLoadingView = true
                                                                         guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                                                                             return
                                                                         }
                                                                         appleName = credential.fullName?.givenName ?? "Please enter your name"
                                                                         self.user.appleAuthenticate(credintial: credential) { b in
                                                                             isLoadingView = false
                                                                             if b == true {
                                                                                 activeSheet = nil
                                                                             } else {
                                                                                 activeSheet = .isRegister
                                                                             }
                                                                         }
                                                                     case .failure(let error):
                                                                         print(error.localizedDescription)
                                                                         isAppleSignInComplete = true
                                                                         appleSingInErrorDescription = error.localizedDescription
                         
                                                                     }
                                                                 }
                                                             )
                                                                 .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                                                                 .frame(width: 375, height: UIScreen.main.bounds.height * 0.05)
                                                                 .clipShape(Capsule())
                                                         }
                                                         Button(action: {
                                                             activeSheet = .isRegister
                                                         }, label: {
                                                             Text("Do not have an account? ")
                                                         })
                                                             .frame(width: 375, height: UIScreen.main.bounds.height * 0.05)
                                                             .clipShape(Capsule())
                         
                                                         Button(action: {
                                                             activeSheet = .isPasswordReset
                                                         }, label: {
                                                             Text("Reset your password")
                                                         })
                                                         //                                    .padding(.horizontal, 30)
                                                     }.frame( alignment: .center)
                                                     .onAppear {
                                                         if colorScheme == .dark {
                                                             backgroundColorTop = Color(red: 63/255, green: 101/255, blue: 131/255, opacity: 51/100)
                                                             backgroundColorBottom = Color(red: 115/255, green: 116/255, blue: 117/255, opacity: 46/100)
                                                         } else {
                                                         backgroundColorTop = Color(red: 148/255, green: 189/255, blue: 227/255, opacity: 89/100)
                                                         backgroundColorBottom = Color(red: 197/255, green: 197/255, blue: 237/255, opacity: 93/100)
                                                         }
                         
                                                     }
                                                 }
                                                 }

                        }
                    }
                    else {
                        VStack {
                            if user.isUploadFinished {
                                Dashboard(isDocumentAddition: $registerView, customDrinkDocument: CustomDrinkViewModel(), userDocument: UserDocument(), backgroundColorTop: $backgroundColorTop, backgroundColorBottom: $backgroundColorBottom)
                                    .environmentObject(HydrationDocument()).onAppear {
                                        print("Button should be true \(user.isUploadFinished)")
                                    }
                            } else {
                                LoadingView()
                            }
                        }
                    }
                }
            }
            .alertView(isPresented: $isLoad, overlayView: {
                LoadingView()
            })
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .isRegister:
                    RegisterView(onCompleteBlock: {activeSheet = nil}, Dashboard: $signIn, registerView: self.$registerView)
                            .environmentObject(user)
                case .isPasswordReset:
                    ResetPassword(onCompleteBlock: {activeSheet = nil}, resetPasswordView: $resetPasswordView)
                }
        
            }

            .alert(isPresented: self.$isAppleSignInComplete, content: {
                Alert(title: Text("Apple Sign-in error"), message: Text(appleSingInErrorDescription), dismissButton: .default(Text("Try Again")))
            })
            .alert(isPresented: self.$isSignInFalse, content: {
                return Alert(title: Text("Error"), message: Text(error), dismissButton: .default(Text("Try Again")))
        })
            .onChange(of: user.loggedIn, perform: {newValue in
                print("user logged In: \(user.loggedIn) user isUpload finished \(user.isUploadFinished)")
            })
            .onChange(of: user.isUploadFinished, perform: { value in
                if value == true {
                    registerView = false
                }
            })
            .onReceive(timer, perform: { _ in
                if self.timeRemaining < 100 {
                    self.timeRemaining += 0.1
                }
            })
            .onAppear{
                print("Ios version is 15")

                print("apple fire store exists \(appleFireStoreExists)")
                if colorScheme == .dark {
                    waterColor = Color( red: 0, green: 0.5, blue: 0.7, opacity: 0.5)
                    borderColor = Color.white
                } else {
                    waterColor = Color( red: 0, green: 0.5, blue: 0.8, opacity: 0.5)
                    borderColor = Color.gray
                }
                if appleLogStatus {
                    if appleFireStoreExists {
                        user.checkUser()
                    }
                } else {
                    user.checkUser()
                }
                colorScheme = ColorScheme
            }
    }
}
