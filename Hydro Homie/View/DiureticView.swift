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
    
    var body: some View {
        
        VStack{
            HStack{
                Text("Log Coffee")
                Image(colorScheme == .light ?  "coffeeBlack" : "coffeeWhite")
            }
            .padding()
            .onTapGesture {
                withAnimation() {
                    isCustomDrink = false
                    isAlcohol = false
                    isCoffee.toggle()
                }
            }
            
            HStack{
                Text("Log alcohol")
                Image(colorScheme == .light ?  "liquorBlack" : "liquorWhite")
            }
            .onTapGesture {
                withAnimation() {
                    isCustomDrink = false
                    isCoffee = false
                    isAlcohol.toggle()
                }
            }
            
            HStack {
                Text("Custom Drink")
            }
            .onTapGesture {
                withAnimation() {
                    isCustomDrink.toggle()
                    isCoffee = false
                    isAlcohol = false
                }
            }
            .padding()
            if isCoffee {
                Text("Black coffee").padding()
                    .onTapGesture {
                        cups += 0.5
                        isDiuretic = false
                        popUp = false // close the popUp for the popUp view
                        print("black coffee \(cups)")
                    }
                Text("Decaf coffee").padding()
                    .onTapGesture {
                        cups += 0.95
                        isDiuretic = false
                        popUp = false // close the popUp for the popUp view
                        print("decaf coffee \(cups)")

                    }
                Text("Starbucks coffees").padding()
                Text("Add custom coffee").padding()
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
                Text("Wine 9%").padding()
                    .onTapGesture {
                        cups += 0.8
                        isDiuretic = false
                        popUp = false // close the popUp for the popUp view
                        print("wine 9%  \(cups)")
                    }
                Text("Beer 5%").padding()
                    .onTapGesture {
                        cups += 0.85
                        isDiuretic = false
                        popUp = false // close the popUp for the popUp view
                        print("wine Beer 5%  \(cups)")
                    }
                Text("Beer 4%").padding()
                    .onTapGesture {
                        cups += 0.9
                    }
            }
            Spacer()
        }
        .sheet(isPresented: $isCustomDrink, content: {
            CustomDrink()
        })
        .sheet(isPresented: $isCustomCoffee, content: {
            TextField("Name of the coffee", text:
            $customCoffeeName)
        })
    }
}


