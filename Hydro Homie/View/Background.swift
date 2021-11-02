//
//  Background.swift
//  Hydro Comrade
//
//  Created by Ismatulla Mansurov on 8/18/21.
//

import Foundation
import SwiftUI

struct Background : View {
    enum drink {
        case water
        case coffee
        case alcohol
    }
    @State private var isCustomWater: Bool = false
    @State private var isCustomCoffee: Bool = false
    @State private var isCustomAlcohol: Bool = false
    //Quick drink menu  variables
    
    @Binding var percentageOfEachAlcohol: Double
    @Binding var amountOfAccumulatedAlcohol: Double
    @Binding var isAlcoholConsumed: Bool
    @Binding var cups: Double
    @Binding var backgroundOpacity: Double
    @Binding var isQuickDrink: Bool
    @Binding var isFirstMenu:Bool
    
    //Coffee
    @Binding var coffeeAmount: Double
    @Binding var accumulatedCoffeeAmount: Double
    @EnvironmentObject var customDrinkDocument: CustomDrinkViewModel
    
    @State private var backgroundColor: Color = Color.black
    //color scheme
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            ZStack {
                Color.black.opacity(backgroundOpacity)
                    .onTapGesture {
                    }
                if backgroundOpacity == 0.6 {
                    withAnimation() {
                        VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
                            .onTapGesture {
                                withAnimation {
                                 backgroundOpacity = 0
                                    isQuickDrink = false
                                }
                            }
                    }
                }
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        backgroundOpacity = 0
                        isQuickDrink = false
                    }, label: {
                        Text("Cancel")
                            .foregroundColor(Color.white)
                    })
                }
                HStack {
                    Spacer()
                    if isQuickDrink {
                        if isFirstMenu {
                            
                            VStack {
                                Spacer().frame(height: UIScreen.main.bounds.size.height / 2)
                                
                                if UIDevice.current.userInterfaceIdiom == .pad {
                                    Spacer().frame(height: UIScreen.main.bounds.size.height / 22)
                                }
                                
                                //MARK: Custom Waters
                                if customDrinkDocument.waterOpacity == 1 {
                                    Button(action: {
                                        withAnimation {
                                            isFirstMenu = false
                                            isCustomWater = true
                                        }
                                        
                                    }, label: {
                                        Image(colorScheme == .dark ? "waterDropDark" : "waterDrop")
                                            .renderingMode(.template)
                                            .foregroundColor(.white)                        })
                                    
                                    if UIDevice.current.userInterfaceIdiom == .pad {
                                        Spacer().frame(height: UIScreen.main.bounds.size.height / 22)
                                    }
                                }
                                //                                //MARK: Custom Coffees
                                if customDrinkDocument.coffeeOpacity == 1 {
                                    Button(action: {
                                        withAnimation {
                                            isFirstMenu = false
                                            isCustomCoffee = true
                                        }
                                    }, label: {
                                        Image(colorScheme == .light ?  "coffee" : "coffeeDark")
                                            .renderingMode(.template)
                                            .foregroundColor(.white)                       })
                                    
                                    if UIDevice.current.userInterfaceIdiom == .pad {
                                        Spacer().frame(height: UIScreen.main.bounds.size.height / 22)
                                    }
                                }
                                //
                                //                                //MARK: Custom Alcohols
                                if customDrinkDocument.alcoholOpacity == 1 {
                                    Button(action: {
                                        withAnimation {
                                            isFirstMenu = false
                                            isCustomAlcohol = true
                                        }
                                    }, label: {
                                        Image(colorScheme == .light ?  "alcohol" : "alcoholDark")
                                            .renderingMode(.template)
                                            .foregroundColor(.white)                    })
                                }
                            }
                            .transition(AnyTransition.move(edge: .bottom))
                        }
                        //
                        if isCustomWater {
                            VStack {
                                Spacer().frame(height: UIScreen.main.bounds.size.height / 3)
                                getDrinkView(drink: drink.water)
                            }.transition(AnyTransition.move(edge: .top))
                            
                        }
                        if isCustomCoffee {
                            VStack {
                                Spacer().frame(height: UIScreen.main.bounds.size.height / 3)
                                getDrinkView(drink: drink.coffee)
                                
                            }.transition(AnyTransition.move(edge: .top))
                        }
                        
                        if isCustomAlcohol {
                            VStack {
                                Spacer().frame(height: UIScreen.main.bounds.size.height / 3)
                                getDrinkView(drink: drink.alcohol)
                                
                            }.transition(AnyTransition.move(edge: .top))
                        }
                    }
                }.padding()
            }
        }
        .onAppear {
            if colorScheme == .light {
                backgroundColor = Color.gray
            }
        }
        .onChange(of: isQuickDrink, perform: { value in
            if !value {
                isCustomWater = false
                isCustomCoffee = false
                isCustomAlcohol = false
                
            }
        })
        
    }
    func getDrinkView(drink: drink) -> some View {
                if drink == .water {
                    return ForEach(customDrinkDocument.customDrinks.filter({$0.isCustomWater}), id: \.self) { drink in
                        Text(drink.name).font(.title)
                            .foregroundColor(.white)
                            .onTapGesture {
                                cups += drink.amount
                                isFirstMenu = false
                                isQuickDrink = false // close the .sheet and go back to the dashboard
                            }
                        Spacer().frame(height: UIScreen.main.bounds.size.height / 22)

                    }
                }
                else if drink == .alcohol {
                    return ForEach(customDrinkDocument.customDrinks.filter({$0.isAlcohol}), id: \.self) { drink in
                        Text(drink.name).font(.title)
                            .foregroundColor(.white)
                            .onTapGesture {
                                cups += drink.amount
                                isFirstMenu = false
                                isQuickDrink = false // close the .sheet and go back to the dashboard
                                isAlcoholConsumed = true
                                self.amountOfAccumulatedAlcohol += drink.alcoholAmount
                                percentageOfEachAlcohol  = drink.alcoholPercentage
                            }
                        Spacer().frame(height: UIScreen.main.bounds.size.height / 22)
                    }
                }
                else {
                    return ForEach(customDrinkDocument.customDrinks.filter({$0.isCaffeine}), id: \.self) { drink in
                        Text(drink.name).font(.title)
                            .foregroundColor(.white)
                            .onTapGesture {
                                cups += drink.amount
                                isFirstMenu = false
                                isQuickDrink = false // close the .sheet and go back to the dashboard
                                coffeeAmount = drink.caffeineAmount / 10000
                                accumulatedCoffeeAmount += drink.caffeineAmount / 10000 //parse grams into mg
                            }
                        Spacer().frame(height: UIScreen.main.bounds.size.height / 22)
                    }
                }
        }
}

