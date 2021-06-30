//
//  CustomDrink.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/30/21.
//

import SwiftUI

struct CustomDrink: View {
    @State private var drinkName: String = ""
    @State private var drinkAmount: Double = 0
    @State private var isAlcohol: Bool = false
    @State private var isCoffee: Bool = false
    @State private var isMilk: Bool = false
    
    //alcoholic beverage details
    @State private var alcoholAmount: Double = 0 //maybe should make picker out of it
    @State private var additionalLiquids: Bool = false
    
    let formatter: NumberFormatter = {
           let formatter = NumberFormatter()
           formatter.numberStyle = .decimal
           return formatter
       }()
    
    
    var body: some View {
        TextField("Name of your drink", text: $drinkName)
            .padding()
        Picker("Is it alcohol ?", selection: $isAlcohol, content: {
            Text("Yes").tag(true)
            Text("No").tag(false)
        })
        .pickerStyle(SegmentedPickerStyle())
        .onAppear {
            isAlcohol = true
        }
        Picker("Is it caffeinated beverage ?", selection: $isCoffee, content: {
            Text("Yes").tag(true)
                .onTapGesture {
                    isAlcohol = true
                }
            Text("No").tag(false)
        })
        .pickerStyle(SegmentedPickerStyle())
        
        if isAlcohol {
            TextField("Amount of alcohol", value: $alcoholAmount, formatter: formatter)
                        .padding()
            Picker("Is it caffeinated beverage ?", selection: $additionalLiquids, content: {
                Text("Yes").tag(true)
                Text("No").tag(false)
            })
            .pickerStyle(SegmentedPickerStyle())
        }
        
    }
}

struct CustomDrink_Previews: PreviewProvider {
    static var previews: some View {
        CustomDrink()
    }
}
