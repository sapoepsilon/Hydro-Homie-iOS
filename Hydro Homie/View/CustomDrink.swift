//
//  CustomDrink.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/30/21.
//

import SwiftUI
import Combine

struct CustomDrink: View {
    
    @State private var drinkName: String = ""
    @State private var drinkAmount: Double = 0
    @State private var isAlcohol: Bool = false
    @State private var isCoffee: Bool = false
    @State private var isWater: Bool = false
    @State private var isMilk: Bool = false
    @State private var ErrorTestDeleteLater: String = "Everything seems to be working OK"
    @EnvironmentObject var CustomDrinkDocument: CustomDrinkViewModel
    @State private var ErrorDetector: Bool = false
    @Binding var isMetric: Bool
    @State private var customWaterAmount: String = ""
    
    //Border Color
    @State private var borderColor: Color = Color.gray
    
    @Binding var isCustomDrinkSheet: Bool
    @Binding var isDiureticSheet: Bool
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
    @State private var alcoholPercentage: String = "" //maybe should make picker out of it
    @State private var alcoholAmount: Double = 0
    @State private var additionalLiquids: Bool = false
    @State private var alcoholCupAmount: String = ""
    @State private var caffeineAmount: Double = 0
    @State private var customDrinks: [CustomDrinkModel] = []
    @State private var mlConverter: Double = 29.5735
    @State private var ethanolDensity: Double = 0.789
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    withAnimation{
                        isCustomDrinkSheet  = false
                    }
                }, label: {
                    Text("Cancel")
                })
            }.padding()
            
            TextField("Name of your drink", text: $drinkName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            VStack(alignment: .leading, spacing: 0) {
                Form {
                    Section(header: Text("Is it pure Water ?")) {
                        Picker("Is it Water ?", selection: $isWater.animation(), content: {
                            Text("Yes") .tag(true)
                            Text("No").tag(false)
                        })
                        .fixedSize()
                        .foregroundColor(.white)
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    if isWater {
                        Section(header: Text("Amount")) {
                            HStack {
                                TextField("Amount of Water", text: $customWaterAmount)
                                    .keyboardType(.numberPad)
                                    .onReceive(Just(customWaterAmount)) { newValue in
                                        let filtered = newValue.filter { "0123456789.".contains($0) }
                                        if filtered != newValue {
                                            customWaterAmount = filtered
                                        }
                                    }
                                Text(cupMeasurement)
                            }
                        }
                    }
                    
                    if !isWater {
                        Section(header: Text("Is it alcohol")) {
                            Picker("Is it alcohol ?", selection: $isAlcohol.animation(), content: {
                                Text("Yes") .tag(true)
                                Text("No").tag(false)
                            })
                            .foregroundColor(.white)
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
                        }.opacity(isWater ? 0 : 1)
                        
                        if isAlcohol {
                            Section(header: Text("Alcoholic beverage: ") ) {
                                    
                                HStack {
                                    TextField("Percentage of alcohol", text: $alcoholPercentage)
                                        .keyboardType(.numberPad)
                                        .onReceive(Just(alcoholPercentage)) { newValue in
                                            let filtered = newValue.filter { "0123456789.".contains($0) }
                                            if filtered != newValue {
                                                alcoholPercentage = filtered
                                            }
                                        }
                                    Text("%")
                                }
                                HStack{
                                        TextField("Cup Amount", text: $alcoholCupAmount)
                                        .keyboardType(.numberPad)
                                        .onReceive(Just(alcoholCupAmount)) { newValue in
                                            let filtered = newValue.filter { "0123456789.".contains($0) }
                                            if filtered != newValue {
                                                alcoholCupAmount = filtered
                                            }
                                        }
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
                                    TextField("Amount of alcohol", value: $alcoholPercentage, formatter: formatter)
                                    Text("%")
                                }
                                HStack{
                                    TextField("Cup Amount", value: $alcoholCupAmount, formatter: formatter)
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
                }
            }
            Button(action: {
                
                let alcoholcupAmount = Double(alcoholCupAmount) ?? 0
                let alcoholpercentage = Double(alcoholPercentage) ?? 0
                if !isWater {
                    drinkAmount = alcoholcupAmount - ((alcoholcupAmount / 100) * alcoholpercentage)
                    alcoholAmount = (alcoholcupAmount * mlConverter) * (alcoholpercentage / 100) * ethanolDensity // get the amount of alcohol in grams
                } else {
                    drinkAmount = Double(customWaterAmount) ?? 0
                }
                
                if isMetric {
                    drinkAmount /= 237
                } else {
                    drinkAmount /= 8
                }
                if drinkAmount != 0 {
                    createCustomDrink(name: drinkName, isAlcohol: isAlcohol, isCaffeine: isCoffee, amount: drinkAmount, alcoholAmount: alcoholAmount, caffeineAmount: caffeineAmount, alcoholPercentage: alcoholpercentage, isCustomWater: isWater)
                    ErrorDetector = true
                    CustomDrinkDocument.getDrinkOpacity()
                } else {
                    borderColor = Color.red
                }
            }
            , label: {
                Text("Create the custom drink")
            })
            
            .buttonStyle(LoginButton())
            .opacity( customWaterAmount.isEmpty && alcoholCupAmount.isEmpty ? 0 : 1)
            
        }
        .alert(isPresented: $ErrorDetector, content: {
            Alert(title: Text("Alert"), message: Text(ErrorTestDeleteLater), dismissButton: .default(Text("OK"), action: {
                withAnimation {
                    isCustomDrinkSheet = false
                    isDiureticSheet = false
                }
            }))
            
        })
        .onAppear {
            cupMeasurement =  isMetric ? "ml" : "oz"
            CustomDrinkDocument.getAllDrinks()
            self.customDrinks = CustomDrinkDocument.customDrinks
            print("custom drink displayed\(CustomDrinkDocument.customDrinks)")
        }
    }
    func createCustomDrink(name: String, isAlcohol: Bool, isCaffeine: Bool, amount: Double, alcoholAmount: Double, caffeineAmount: Double, alcoholPercentage: Double, isCustomWater: Bool) {
        
        ErrorTestDeleteLater = CustomDrinkDocument.addCustomDrink(newCustomDrink: CustomDrinkModel(id: CustomDrinkDocument.customDrinks.count, name: name, isAlcohol: isAlcohol, isCaffeine: isCaffeine, amount: amount, alcoholAmount: alcoholAmount, alcoholPercentage: alcoholPercentage, caffeineAmount: caffeineAmount, isCustomWater: isCustomWater))
    }
    
    
}
