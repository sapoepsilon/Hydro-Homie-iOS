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
    
    
    // metrics
    //@Binding isMetric: Bool
    //TODO: link to the user's metric system
    @State private var cupMeasurement: String = "OZ"
    
    
    //different beverages
    enum differentLiquids: String, CaseIterable, Identifiable {
        case milk
        case soda
        case dietSoda
        case milkAlternatives
        case sugaryJuice
        case naturalJuice
        
        var id: String { self.rawValue }
    }
    @State private var selectedLiquid = differentLiquids.milk
    
    //alcoholic beverage details
    @State private var alcoholAmount: String = "" //maybe should make picker out of it
    @State private var additionalLiquids: Bool = false
    @State private var alcoholCupAmount: String = ""
    
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    
    var body: some View {
        VStack(alignment: .leading) {
            
            TextField("Name of your drink", text: $drinkName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Form {
                Section(header: Text("Is it alcohol")) {
                    Picker("Is it alcohol ?", selection: $isAlcohol.animation(), content: {
                        Text("Yes") .tag(true)
                        Text("No").tag(false)
                    })
                    .pickerStyle(SegmentedPickerStyle())
                    .fixedSize()
                }
                Section(header: Text("Is it coffeinated beverage")) {
                    Picker("Is it caffeinated beverage ?", selection: $isCoffee.animation(), content: {
                        Text("Yes")
                            .animation(.easeInOut)
                            .tag(true)
                        Text("No").tag(false)
                    })
                    .fixedSize()
                    .pickerStyle(SegmentedPickerStyle())
                }
            
            if isAlcohol {
                    Section(header: Text("Alcoholic beverage: ") ) {
                        
                        TextField("Amount of alcohol", value: $alcoholAmount, formatter: formatter)
                        HStack{
                            TextField("Cup Amount", text: $alcoholCupAmount)
                            Text(cupMeasurement)
                        }
                        Picker("Additional liquids in the beverage ?", selection: $additionalLiquids, content: {
                            Text("Yes").tag(true)
                            Text("No").tag(false)
                        })
                        .pickerStyle(MenuPickerStyle())
                        if additionalLiquids {
                            Picker("Different liquids: ", selection: $selectedLiquid,
                                   content: {
                                    Text("Milk").tag(differentLiquids.milk)
                                    Text("Regular soda").tag(differentLiquids.soda)
                                    Text("Diet soda").tag(differentLiquids.dietSoda)
                                    Text("Milk alternatives").tag(differentLiquids.milkAlternatives)
                                    Text("Regular Juice").tag(differentLiquids.sugaryJuice)
                                    Text("Freshlly Squeezed Juice").tag(differentLiquids.naturalJuice)
                                   })
                                .pickerStyle(WheelPickerStyle())
                        }
                    }
                }
            if isCoffee {
                    Section(header: Text("Coffee beverage: ") ) {
                        HStack {
                            TextField("Amount of alcohol", value: $alcoholAmount, formatter: formatter)
                            Text("%")
                        }
                        HStack{
                            TextField("Cup Amount", text: $alcoholCupAmount)
                            Text(cupMeasurement)
                        }
                        Picker("Additional liquids in the beverage ?", selection: $additionalLiquids, content: {
                            Text("Yes").tag(true)
                            Text("No").tag(false)
                        })
                        .pickerStyle(MenuPickerStyle())
                        if additionalLiquids {
                            Picker("Different liquids: ", selection: $selectedLiquid,
                                   content: {
                                    Text("Milk").tag(differentLiquids.milk)
                                    Text("Regular soda").tag(differentLiquids.soda)
                                    Text("Diet soda").tag(differentLiquids.dietSoda)
                                    Text("Milk alternatives").tag(differentLiquids.milkAlternatives)
                                    Text("Regular Juice").tag(differentLiquids.sugaryJuice)
                                    Text("Freshlly Squeezed Juice").tag(differentLiquids.naturalJuice)
                                   })
                                .pickerStyle(WheelPickerStyle())
                        }
                    }
                }
            }
            
            Spacer()
            
        }
    }
}

struct CustomDrink_Previews: PreviewProvider {
    static var previews: some View {
        CustomDrink()
    }
}
