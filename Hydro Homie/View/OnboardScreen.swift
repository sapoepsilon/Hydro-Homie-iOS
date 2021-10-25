//
//  OnboardScreen.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 10/9/21.
//

import SwiftUI

struct OnboardScreen: View {
    @AppStorage("welcomePage") var isWelcomePageShown: Bool = UserDefaults.standard.isWelcomePageShown
    @Environment(\.colorScheme) var colorScheme
    
    @State private var waterPercentage: Double = 60
    @State private var isCustomWater: Bool = false
    @State private var isDiuretic: Bool = false
    @State private var waterColor: Color = Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5)
    @Binding var backgroundColorTop: Color
    @Binding var backgroundColorBottom: Color
    @State private var toolBar: UIToolbar = UIToolbar()
    @State private var welcomeText: String = "Hydro Comrade will help you to log your water, alcohol or coffee."
    //Onboarding screen variables
    @State private var onBoardValue: Double = 0
    @State private var stepperSсale: Double = 1
    @State private var waterDropOpacity: Double = 0
    @State private var waterDropScale:CGFloat = 1
    @State private var stepperOpacity: Double = 0
    @State private var quickDrinkOpacity: Double = 1
    @State private var dropScale: Double = 1.75
    @State private var dropOpacity: Double = 1
    @State private var arrowXValue:CGFloat = 0
    @State private var dropOffset: CGSize = CGSize.zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(gradient: Gradient(colors: [backgroundColorTop , backgroundColorBottom]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.vertical)
                if onBoardValue == 3 || onBoardValue == 4 {
                    Arrow()
                        .foregroundColor(waterColor)
                        .rotationEffect(.degrees(-180))
                        .animation(.easeInOut(duration: 0.35)).transition(.verticalSlide(-180)).zIndex(1)
                        .frame(width: geometry.size.width / 3, height: geometry.size.height / 6)
                        .offset(x: arrowXValue, y: geometry.size.height / 2.8)
                        .transition(.slide)
                }
                VStack {
                    HStack{
                        Spacer()
                        skipButton()
                        Spacer().frame(width: geometry.size.width / 10)
                    }
                    Text("Welcome to")
                        .foregroundColor(.white)
                        .font(.system(size: geometry.size.height * 0.04))
                        .transition(.slide)
                    
                    Text("Hydro Homie")
                        .foregroundColor(waterColor)
                        .font(.system(size: geometry.size.height * 0.09))
                        .transition(.slide)
                    
                    waterView()
                        .offset(x: dropOffset.width * 5, y: dropOffset.height * 5)
                        .transition(.slide)
                        .offset(dropOffset)
                    
                    stepper()
                    HStack {
                        nextButton(geometry: geometry)
                    }.padding(.vertical)
                    HStack {
                        Spacer().frame(width: UIScreen.main.bounds.size.width / 2 - (UIScreen.main.bounds.size.width / 48.75))
                        drop()
                        Spacer()
                        plus().padding()
                    }
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }

        }
    
        
    }
    
    func drop() -> some View {
        return Image(systemName: "drop")
            .scaleEffect(dropScale)
            .opacity(dropOpacity)
        
    }
    func plus() -> some View {
        return  Image(systemName: "plus")
            .opacity(quickDrinkOpacity)
            .scaleEffect(2)
            .foregroundColor(waterColor)
    }
    func waterView() -> some View {
        return VStack {
            WaterView(factor: $waterPercentage, waterColor: $waterColor, backgroundColor: $backgroundColorBottom).scaleEffect(waterDropScale)
            
        }.animation(.easeInOut(duration: 0.75))
    }
    func skipButton() -> some View {
        return Button(action: {
            isWelcomePageShown = true
        }, label: {
            Text("Skip").zIndex(1)
        }).frame(width: UIScreen.main.bounds.width / 3)
    }
    func nextButton(geometry: GeometryProxy) -> some View {
        return ZStack {
            Button(
                action: {
                    if onBoardValue == 0 {
                        withAnimation(.easeInOut(duration: 1)) {
                            onBoardValue += 1
                            stepperOpacity = 1
                            stepperSсale = 1.5
                            welcomeText = "This is a water stepper. Pressing this button would add 8 ounces of water towards your daily goal"
                        }
                    } else if onBoardValue == 1 {
                        withAnimation(.easeInOut(duration: 1)) {
                            welcomeText = "This water drop indicates your daily goal of water. If it is filled with water. Great job! Else, you should be drinking more water"
                            stepperOpacity = 0
                            stepperSсale = 1
                            onBoardValue += 1
                            waterDropScale = 1.75
                            waterDropOpacity = 1
                        }
                    } else if onBoardValue == 2 {
                        withAnimation(.easeInOut(duration: 1)) {
                            welcomeText = "Here, you will be able to add your custom drinks, which may contain alchol or caffeine."
                            waterDropScale = 1
                            waterDropOpacity = 0
                            dropScale = 3
                            dropOpacity = 1
                            onBoardValue += 1
                        }
                    } else if onBoardValue == 3 {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            welcomeText = "The drinks that you will create can be accessed on the right bottom corner of the App: "
                            dropOpacity = 0
                            dropScale = 1.75
                            onBoardValue += 1
                            arrowXValue = geometry.size.width / 2.2674
                        }
                        
                    } else if onBoardValue == 4 {
                        welcomeText = "If you slide the waterDrop to the left, the color of the water drop will change to light green; indicating the past dates. One slide equals to one day."
                        
                        withAnimation(.easeInOut(duration: 0.5)) {
                            waterColor =  Color(red: 103 / 255, green: 146 / 255, blue: 103 / 255, opacity: 0.5)
                            quickDrinkOpacity = 0
                            onBoardValue += 1
                        }
                        
                    } else if onBoardValue == 5 {
                        welcomeText = "When the color is light purple, it means that you are consuming diuretic drinks such as, alcohol and caffeine"
                        
                        withAnimation(.easeInOut(duration: 0.5)) {
                            waterColor = Color(red: 130 / 255, green: 98 / 255, blue: 222 / 255, opacity: 0.5)
                            onBoardValue += 1
                        }
                    } else if onBoardValue == 6 {
                        withAnimation {
                            isWelcomePageShown = true
                        }
                    }
                }, label: {
                        Text("Next").zIndex(1)
                })
                .buttonStyle(LoginButton())
        }
    }
    func stepper() -> some View {
        return VStack {
            CustomStepper(value: $waterPercentage, isDiuretic: $isDiuretic, textColor: $waterColor, isCustomWater: $isCustomWater)
                .scaleEffect(stepperSсale)
            WelcomeBoardText(text: welcomeText)        .frame(width: UIScreen.main.bounds.width * 0.8)
        }
        
    }
}
