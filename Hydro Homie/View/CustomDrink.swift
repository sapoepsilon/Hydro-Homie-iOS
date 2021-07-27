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
    @State private var ErrorTestDeleteLater: String = "Everything seems to be working OK"
    @ObservedObject var CustomDrinkDocument: CustomDrinkViewModel
    @State private var ErrorDetector: Bool = false
    @Binding var isMetric: Bool
    
    
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
    @State private var alcoholPercentage: Double = 0 //maybe should make picker out of it
    @State private var alcoholAmount: Double = 0
    @State private var additionalLiquids: Bool = false
    @State private var alcoholCupAmount: Double = 0
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
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                        drinkAmount = alcoholCupAmount - ((alcoholCupAmount / 100) * alcoholPercentage)
                        alcoholAmount = (alcoholCupAmount * mlConverter) * (alcoholPercentage / 100) * ethanolDensity // get the amount of alcohol in grams
                
                    if isMetric {
                        drinkAmount /= 237
                    } else {
                        drinkAmount /= 8
                    }
                    print("drink amount \(drinkAmount)")
                    createCustomDrink(name: drinkName, isAlcohol: isAlcohol, isCaffeine: isCoffee, amount: drinkAmount, alcoholAmount: alcoholAmount, caffeineAmount: caffeineAmount, alcoholPercentage: alcoholPercentage)
                    ErrorDetector = true
                }
                , label: {
                    Text("Add CustomDrink")
                })
            }.padding()
            
            TextField("Name of your drink", text: $drinkName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Form {
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
                }
                
                if isAlcohol {
                    Section(header: Text("Alcoholic beverage: ") ) {
                        
                        TextField("Amount of alcohol", value: $alcoholPercentage, formatter: formatter)
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
        .alert(isPresented: $ErrorDetector, content: {
            Alert(title: Text("Error"), message: Text(ErrorTestDeleteLater), dismissButton: .cancel())
        })
        .onAppear {
          CustomDrinkDocument.getAllDrinks()
            self.customDrinks = CustomDrinkDocument.customDrinks
            print("custom drink displayed\(CustomDrinkDocument.customDrinks)")
        }
    }
    func createCustomDrink(name: String, isAlcohol: Bool, isCaffeine: Bool, amount: Double, alcoholAmount: Double, caffeineAmount: Double, alcoholPercentage: Double) {
        
        ErrorTestDeleteLater = CustomDrinkDocument.addCustomDrink(newCustomDrink: CustomDrinkModel(id: CustomDrinkDocument.customDrinks.count, name: name, isAlcohol: isAlcohol, isCaffeine: isCaffeine, amount: amount, alcoholAmount: alcoholAmount, alcoholPercentage: alcoholPercentage, caffeineAmount: caffeineAmount))
    }
    
    
}
