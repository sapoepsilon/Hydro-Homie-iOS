//
//  DiureticView.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/28/21.
//

import SwiftUI

struct DiureticView: View {
    @State private var isCoffee: Bool = false
    @State private var isCustomCoffee: Bool = false
    @State private var customCoffeeName: String = ""
    @Binding var popUp: Bool
    @Binding var cups: Double
    @Binding var isDiuretic: Bool
    @State private var isAlcohol: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @State private var isCustomDrink: Bool = false
    @State private var scaleEffect: CGFloat = 1
    @State private var backgroundColor: Color = Color.black
    @Binding var waterColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
                    .edgesIgnoringSafeArea(.all )
                    .opacity(0.9)
            }.blur(radius: 3, opaque: false)
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isDiuretic = false
                    }, label: {
                        Text("Done")
                    })
                    .padding(.horizontal, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)

                }
                Spacer().frame(width: geometry.size.width, height: geometry.size.height / 3.80, alignment: .center)
                if !isCustomDrink || !isCoffee || !isAlcohol {
                    HStack {
                        //                        Text("Log Water")
                        Image(colorScheme == .dark ? "waterDropDark" : "waterDrop")
                            .renderingMode(.template)
                            .foregroundColor(colorScheme == .light ? waterColor : .white)
                            .scaleEffect(2)
                    }
                    .opacity(isCoffee ? 0 : 1)
                    .padding()
                    .onTapGesture {
                        cups += 1
                        isDiuretic = false
                    }
                    Text("Log Water")
                    HStack{
                        //                        Text("Log Coffee")
                        Image(colorScheme == .light ?  "coffee" : "coffeeDark")
                            .renderingMode(.template)
                            .foregroundColor(colorScheme == .light ? waterColor : .white)
                            .scaleEffect(2)
                    }
                    .opacity(isCoffee ? 0 : 1)
                    .padding()
                    .onTapGesture {
                        withAnimation() {
                            isCustomDrink = false
                            isAlcohol = false
                            isCoffee.toggle()
                        }
                    }
                    Text("Log Coffee")
                    
                    HStack{
                        //                        Text("Log alcohol")
                        Image(colorScheme == .light ?  "alcohol" : "alcoholDark")
                            .renderingMode(.template)
                            .foregroundColor(colorScheme == .light ? waterColor : .white)
                            .scaleEffect(2)
                    }
                    .opacity(isCoffee ? 0 : 1)
                    .padding()
                    .onTapGesture {
                        withAnimation() {
                            isCustomDrink = false
                            isCoffee = false
                            isAlcohol.toggle()
                        }
                    }
                    Text("Log Alcohol")

                    HStack {
                        Text("Custom Drink")
                            .fontWeight(.bold  )
                            .foregroundColor(colorScheme == .light ? waterColor : .white)
                    }
                    .opacity(isCoffee ? 0 : 1)
                    .onTapGesture {
                        withAnimation() {
                            isCustomDrink.toggle()
                            isCoffee = false
                            isAlcohol = false
                        }
                    }
                    .scaleEffect(2)
                    .padding()
                    
                    
                }
                else {
                    if isCoffee {
                        Text("Black coffee").padding()
                            .onTapGesture {
                                cups += 0.5
                                isDiuretic = false
                                popUp = false // close the popUp for the popUp view
                                print("black coffee \(cups)")
                            }
                            .foregroundColor(colorScheme == .light ? waterColor : .white)

                        Text("Decaf coffee").padding()
                            .onTapGesture {
                                cups += 0.95
                                isDiuretic = false
                                popUp = false // close the popUp for the popUp view
                                print("decaf coffee \(cups)")
                                
                            }
                            .foregroundColor(colorScheme == .light ? waterColor : .white)

                        Text("Starbucks coffees").padding()
                            .foregroundColor(colorScheme == .light ? waterColor : .white)

                        Text("Add custom coffee").padding()
                            .foregroundColor(colorScheme == .light ? waterColor : .white)
                            .onTapGesture {
                                isCustomCoffee.toggle()
                            }
                    }
                    if isAlcohol {
                        Text("Liquor 40%").padding()
                            .onTapGesture {
                                cups += 0.40
                                isDiuretic = false
                                popUp = false // close the popUp for the popUp view
                                print("liquor  \(cups)")
                            }
                            .foregroundColor(colorScheme == .light ? waterColor : .white)

                        Text("Wine 9%").padding()
                            .onTapGesture {
                                cups += 0.8
                                isDiuretic = false
                                popUp = false // close the popUp for the popUp view
                                print("wine 9%  \(cups)")
                            }
                            .foregroundColor(colorScheme == .light ? waterColor : .white)

                        Text("Beer 5%").padding()
                            .onTapGesture {
                                cups += 0.85
                                isDiuretic = false
                                popUp = false // close the popUp for the popUp view
                                print("wine Beer 5%  \(cups)")
                            }
                            .foregroundColor(colorScheme == .light ? waterColor : .white)

                        Text("Beer 4%").padding()
                            .onTapGesture {
                                cups += 0.9
                            }
                            .foregroundColor(colorScheme == .light ? waterColor : .white)

                    }
                }
            }

        }
        .scaleEffect(scaleEffect)
        .padding()
        .onAppear {
            if(colorScheme == .light ) {
                backgroundColor = Color.white
            }
            if UIDevice.current.userInterfaceIdiom == .pad {
                scaleEffect = 1.5
            }
        }
        
        //        VStack{
        //
        //
        //
        //        }
        
        .sheet(isPresented: $isCustomDrink, content: {
            CustomDrink()
                .clearModalBackground()
        })
        .sheet(isPresented: $isCustomCoffee, content: {
            TextField("Name of the coffee", text:
                        $customCoffeeName)
        })
        
        
        Spacer()
    }
    
    
}


