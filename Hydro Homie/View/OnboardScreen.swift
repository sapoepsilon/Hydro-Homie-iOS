//
//  OnboardScreen.swift
//  Hydro Comrade
//
//  Created by Ismatulla Mansurov on 10/9/21.
//

import SwiftUI

struct OnboardScreen: View {
    @AppStorage("welcomePage") var isWelcomePageShown: Bool = UserDefaults.standard.isWelcomePageShown
    @State var colorScheme: ColorScheme =  ColorScheme.light
    @State private var clearColor: Color = Color.clear
    @Binding var waterColor: Color
    @State private var currentIndex: Int  = 0
    @State var waterFactor: Double  = 50

    var views: [OnBoardModel] = []
    init(waterColor: Binding<Color>) {
        self._waterColor = waterColor
        views = [
            OnBoardModel(title: "Welcome", subtitle: "to Hydro Comrade", description: "Hydro Comrade helps you to track your water and diuretic consumption, and compensate any diuretic effects",  pic: colorScheme == .dark ? ("LaunchWaterDropDark", "StepperDarK") : ("LaunchWaterDropLight", "StepperLight"), color: Color.clear),
            OnBoardModel( title: "Water Drop", subtitle: "Add Water", description: "Add 8 ounces of cup or 250ml by tapping on the water drop",pic: ("", ""),color: Color.clear),
            OnBoardModel(title: "Custom Drinks", subtitle: "Your custom drinks", description: " Create a custom drink, and log your custom drinks", pic: ("CustomDrinks", nil), color: Color.clear),
            OnBoardModel(title: "Diuretic Mode", subtitle: "Alcohol and caffeineted drinks", description: "The app knows when you are body in the diuretic mode, and notifies whether you should consume more water.", pic: ("Diuretic", nil), color: Color.clear),
            OnBoardModel(title: "Diuretic Mode", subtitle: "Alcohol and caffeineted drinks", description: "The app knows when you are body in the diuretic mode, and notifies whether you should consume more water.", pic: ("Diuretic", nil), color: Color.clear)
        ]
    }

    var body: some View {
        ZStack {
            OnBoardView(view: views[currentIndex])
                .transition(.slide)
                .ignoresSafeArea()
        }

    }
    @ViewBuilder
    func OnBoardView(view: OnBoardModel) -> some View {
        ZStack {
            view.color
        VStack {
            VStack(spacing: 0) {
                HStack {
                    Text(view.title)
                        .font(.system(size: 40))
                    Spacer()
                    Button(action: {
                        isWelcomePageShown = false
                    }, label: {
                        Text("SKIP")
                    }) .foregroundColor(.white)
                        .padding()
                        .cornerRadius(8)
                }

                Text(view.subtitle)
                    .font(.system(size: 25, weight: .bold))
            } .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .top], 20)
                .padding([.trailing, .top])
                .transition(.slide)
            VStack(spacing:0) {
                if currentIndex == 1 {
                    WaterView(factor: waterFactor, waterColor: $waterColor, backgroundColor: $clearColor)
                } else {
                    Image(view.pic.0).resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding([.leading, .trailing], -10)
                        .transition(.slide)
                    if view.pic.1 != nil {
                        Image(view.pic.1!).offset(x: 0)
                            .scaleEffect(0.5)
                            .aspectRatio(contentMode: .fit)

                    }
                }
            }                    .transition(.slide)

            VStack( spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut) {
                            if currentIndex != 0 {
                                currentIndex -= 1
                            }
                        }
                    }, label: {
                        Text("BACK").foregroundColor(Color.white)
                    }) .foregroundColor(.white)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(8)
                    Button(action: {
                        print("current INdex: \(currentIndex)")
                        print("isWelcome page shown\(isWelcomePageShown)")
                        withAnimation(.easeInOut) {
                            currentIndex += 1
                            if currentIndex == 4 {
                                isWelcomePageShown = false
                            }
                        }
                    }, label: {
                        Text(currentIndex == 3 ? "Login" : "NEXT").foregroundColor(Color.white)
                    }) .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                    Spacer()
                }
                Text(view.description)
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .frame(width: getRect().width - 100)
                    .padding(.top)
                    .lineSpacing(8)
                    .aspectRatio( contentMode: .fit)
            }                    .transition(.slide)

                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding([.trailing, .bottom], 20)
        }
        .transition(.slide)

        }


    }
}


struct LiquidShape: Shape {
    var offset: CGSize

    func path(in rect: CGRect) -> Path {
        return Path { path in
            let width = rect.width + (-offset.width > 0 ? offset.width : 0)

            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))

            let form = 80 + (offset.width)
            path.move(to: CGPoint(x: rect.width, y: form > 80 ? 80: form))
            var to =  180 + (offset.height) + (-offset.width)
            to = to < 180 ? 180 : to

            let mid: CGFloat = 80 + ((to-80) / 2)
            path.addCurve(to: CGPoint(x:rect.width, y: to), control1: CGPoint(x: width - 50, y: mid), control2: CGPoint(x: width - 50, y: mid))
        }
    }
}

