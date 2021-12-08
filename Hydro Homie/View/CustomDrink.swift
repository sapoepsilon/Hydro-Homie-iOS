//
//  CustomDrink.swift
//  Hydro Comrade
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
    @State  var ErrorTestDeleteLater: String = "Everything seems to be working OK"
    @EnvironmentObject var CustomDrinkDocument: CustomDrinkViewModel
    @State  var ErrorDetector: Bool = false
    @Binding var isMetric: Bool
    @State private var customWaterAmount: String = ""
    @State private var additionalBeverageAmount: Double = 0
    @State private var maxAmountBeverageAmount: Double = 0
    //Border Color
    @State private var borderColor: Color = Color.gray
    
    @Binding var isCustomDrinkSheet: Bool
    @Binding var isDiureticSheet: Bool
    // metrics
    //@Binding isMetric: Bool
    //TODO: link to the user's metric system
    @State private var cupMeasurement: String = "OZ"
    //different beverages
    enum differentLiquids: String, CaseIterable, Equatable {
        case milk
        case soda
        case dietSoda
        case milkAlternatives
        case sugaryJuice
        case naturalJuice
        var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
    }
    
    @State private var selectedLiquid = differentLiquids.milk
    //alcoholic beverage details
    @State private var alcoholPercentage: String = ""
    @State private var alcoholAmount: Double = 0
    @State private var additionalLiquids: Bool = false
    @State private var alcoholCupAmount: String = ""
    @State private var caffeineAmount: String = ""
    @State private var isError: Bool = false
    @State private var customDrinks: [CustomDrinkModel] = []
    @State private var mlConverter: Double = 29.5735
    @State private var ethanolDensity: Double = 0.789
    @State private var differentBeverageName = "What kind of beverage"
    @State private var isCaffeineInfo: Bool = false
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
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(self.drinkName == "" ? borderColor : Color.green, lineWidth: 2)
                )
                .keyboardType(UIKeyboardType.alphabet   )
                .padding()
            VStack(alignment: .leading, spacing: 0) {
                Form {
                    if !isCoffee && !isAlcohol {
                        HStack {
                            Text("Is it pure Water ?")
                            Picker("Is it pure Water ?", selection: $isWater.animation(.linear(duration: 0.03)), content: {
                                Text("Yes").tag(true)
                                Text("No").tag(false)
                            })
                            .pickerStyle(MenuPickerStyle())
                        }.transition(.slide)
                    }
                    if isWater && !isCoffee && !isAlcohol {
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
                            }.transition(.slide)
                    }
                    
                    if !isWater && !isCoffee {
                        HStack {
                            Text("Is it alcohol?")
                                Picker("Is it alcohol ?", selection: $isAlcohol.animation(.linear(duration: 0.03)), content: {
                                    Text("Yes").tag(true)
                                    Text("No").tag(false)
                                })
                                    .foregroundColor(.white)
                                    .pickerStyle(MenuPickerStyle())
                        }.transition(.slide)
                    }
                    if !isWater && !isAlcohol {
                        HStack {
                            Text("Is it coffeinated beverage?")
                            Picker("Is it caffeinated beverage ?", selection: $isCoffee.animation(.linear(duration: 0.03)), content: {
                                Text("Yes").tag(true)
                                Text("No").tag(false)
                            })
                                .pickerStyle(MenuPickerStyle())
                    }
                    }
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
                            HStack {
                                Text("Additional beverages in your drink?")
                                Picker("Additional liquids in the beverage ?", selection: $additionalLiquids, content: {
                                    Text("No").tag(false)
                                    Text("Yes").tag(true)
                                })
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            if additionalLiquids {
                                withAnimation {
                                    Menu(content: {
                                        ForEach(differentLiquids.allCases, id: \.self   ) { liquid in
                                            Button(action: {
                                                selectedLiquid = liquid
                                                differentBeverageName = liquid.rawValue.camelCaseToWords()
                                                
                                            }, label: {
                                                Text(liquid.rawValue.camelCaseToWords())
                                            })
                                        }
                                    }, label: {
                                        Text(differentBeverageName)
                                    })
                                }
                                HStack{
                                    if alcoholCupAmount.isEmpty && alcoholPercentage.isEmpty  {
                                        
                                    } else {
                                        Menu(content: {
                                            ForEach((1..<Int(maxAmountBeverageAmount)).reversed(), id: \.self) { number in
                                                Button(action: {
                                                    additionalBeverageAmount = Double(number)
                                                }, label: {
                                                    Text("\(String(number)) \(cupMeasurement)")
                                                })
                                            }
                                        }, label: {
                                            Text("Amount of beverage")
                                        })
                                        Text("Amount: \(additionalBeverageAmount, specifier: "%.f")").opacity(additionalBeverageAmount > 0 ? 1 : 0)
                                    }
                                }
                            }
                        }.transition(.slide)
                    }
                    
                    if isCoffee {
                        Section(header: Text("Coffee beverage: ") ) {
                            HStack {
                                
                                TextField("Amount of caffeine in mg", text: $caffeineAmount)
                                    .keyboardType(.numberPad)
                                    .onReceive(Just(caffeineAmount)) { newValue in
                                        let filtered = newValue.filter { "0123456789.".contains($0) }
                                        if filtered != newValue {
                                            caffeineAmount = filtered
                                        }
                                    }
                                Text("mg")
                                Button(action: {
                                    isCaffeineInfo = true
                                }, label: {
                                    Image(systemName: "info")
                                })
                            }
                            HStack{
                                TextField("Cup Amount", text: $alcoholCupAmount)
                                    .keyboardType(.numberPad)
                                    .onReceive(Just(caffeineAmount)) { newValue in
                                        let filtered = newValue.filter { "0123456789.".contains($0) }
                                        if filtered != newValue {
                                            caffeineAmount = filtered
                                        }
                                    }
                                Text(cupMeasurement)
                            }
                            Picker("Additional liquids in the beverage ?", selection: $additionalLiquids, content: {
                                Text("No").tag(false)
                                Text("Yes").tag(true)
                            })
                                .pickerStyle(SegmentedPickerStyle())
                            
                            if additionalLiquids && alcoholCupAmount != "" && alcoholPercentage != "" {
                                Menu(content: {
                                    ForEach(differentLiquids.allCases, id: \.self   ) { liquid in
                                        Button(action: {
                                            selectedLiquid = liquid
                                            differentBeverageName = liquid.rawValue.camelCaseToWords()
                                            
                                        }, label: {
                                            Text(liquid.rawValue.camelCaseToWords())
                                        })
                                    }
                                }, label: {
                                    Text(differentBeverageName)
                                })
                                HStack{
                                    Menu(content: {
                                        ForEach((1...Int(maxAmountBeverageAmount)).reversed(), id: \.self) { number in
                                            Button(action: {
                                                additionalBeverageAmount = Double(number)
                                            }, label: {
                                                Text(String(number))
                                            })
                                        }
                                    }, label: {
                                        Text("Amount of beverage")
                                    })
                                }
                            }
                        }.transition(.slide)
                    }
                }.transition(.slide)
            }
            if additionalLiquids {
                if additionalBeverageAmount != 0 {
                    addDrinkButton(completionHandler: { isError, feedback in
                        if isError {
                            isCustomDrinkSheet = false
                            isDiureticSheet = false
                            print(ErrorDetector)
                            
                        } else {
                            ErrorTestDeleteLater = feedback
                            self.isError = true
                        }
                    })
                }
            } else if !additionalLiquids {
                if isCoffee {
                    addDrinkButton(completionHandler: { isDrink, feedback in
                        if isDrink {
                            ErrorTestDeleteLater = feedback
                            isError  = true
                            print(ErrorDetector)
                            
                        } else {
                            ErrorTestDeleteLater = feedback
                            isError = true
                        }
                    })                        .opacity( caffeineAmount.isEmpty || alcoholCupAmount.isEmpty ? 0 : 1)
                } else if isWater {
                    addDrinkButton(completionHandler: { isDrink, feedback in
                        if isDrink {
                            ErrorTestDeleteLater = feedback
                            isError = true
                            print(ErrorDetector)
                            
                        } else {
                            ErrorTestDeleteLater = feedback
                            isError = true
                        }
                    })
                        .opacity(customWaterAmount.isEmpty ? 0 : 1)
                        .padding()
                        .buttonStyle(LoginButton())
                } else {
                    addDrinkButton(completionHandler: { isDrink, feedback in
                        if isDrink {
                            ErrorTestDeleteLater = feedback
                            isError = true
                            print(ErrorDetector)
                            
                        } else {
                            ErrorTestDeleteLater = feedback
                            isError = true
                        }
                    })                        .opacity( alcoholPercentage.isEmpty || alcoholCupAmount.isEmpty ? 0 : 1)
                }
            }
        }
        .alertView(isPresented: $isError, overlayView: {
            VStack {
                Text(ErrorTestDeleteLater)
                Button(action: {
                    isError = false
                    isDiureticSheet = false
                    isCustomDrinkSheet = false
                }, label: {
                    Text("OK")
                })
            }
        })
        .alertView(isPresented: $isCaffeineInfo, blurRadius:3 , overlayView: {
            VStack {
                Text(" For any amount of 'good strength' American-style coffee by any brew method, weigh the dry coffee in grams and multiply by 0.008, or 80mg of caffeine for each 10g of dry coffee.." ).padding(.horizontal, 60)
                HStack {
                    Button(action: {
                        isCaffeineInfo = false
                    }, label: {
                        Text("OK")
                    })
                    Button(action: {
                        UIApplication.shared.open(URL(string: "https://coffee.stackexchange.com/a/324")!)
                    }, label: {
                        Text("Learn more")
                    })
                }
            }
        })
        
        .onAppear {
            if isMetric {
                mlConverter = 1
            }
            cupMeasurement =  isMetric ? "ml" : "oz"
            CustomDrinkDocument.getAllDrinks()
            self.customDrinks = CustomDrinkDocument.customDrinks
        }
        .onChange(of: alcoholCupAmount, perform: { value in
            if alcoholPercentage != "" && alcoholCupAmount != "" {
                let alcoholcupAmount = Double(alcoholCupAmount) ?? 0
                //                let alcoholpercentage = Double(alcoholPercentage) ?? 0
                //                let localDrinkAmount = alcoholcupAmount - ((alcoholcupAmount / 100) * alcoholpercentage)
                //                print("drink amount \(localDrinkAmount)")
                //                let localAlcoholAmount = (alcoholcupAmount * mlConverter) * (alcoholpercentage / 100) * ethanolDensity
                //                let returnAmount = localDrinkAmount - localAlcoholAmount
                //                print("drink amount \(returnAmount)" )
                maxAmountBeverageAmount = alcoholcupAmount
            }
        })
    }
    func addDrinkButton(completionHandler: @escaping (Bool, String) -> Void) -> some View {
        return  Button(action: {
            if drinkName != "" {
                var alcoholcupAmount = Double(alcoholCupAmount) ?? 0
                let alcoholpercentage = Double(alcoholPercentage) ?? 0
                let cupAmount = Double(alcoholCupAmount) ?? 0
                if !isWater {
                    alcoholcupAmount -= additionalBeverageAmount
                    drinkAmount = cupAmount - ((alcoholcupAmount / 100) * alcoholpercentage)
                    alcoholAmount = (alcoholcupAmount * mlConverter) * (alcoholpercentage / 100) * ethanolDensity // get the amount of alcohol in grams
                } else {
                    drinkAmount = Double(customWaterAmount) ?? 0
                }
                let caffeineAmount = Double(caffeineAmount) ?? 0
                if isMetric {
                    drinkAmount /= 237
                } else {
                    drinkAmount /= 8
                }
                if drinkAmount != 0 {
                    createCustomDrink(name: drinkName, isAlcohol: isAlcohol, isCaffeine: isCoffee, amount: drinkAmount, alcoholAmount: alcoholAmount, caffeineAmount: caffeineAmount, alcoholPercentage: alcoholpercentage, isCustomWater: isWater, completionHandler: { isDrink, feedBack in
                        completionHandler(isDrink, feedBack)
                    })
                    //                ErrorDetector = true
                    CustomDrinkDocument.getDrinkOpacity()
                    //                isCustomDrinkSheet = false
                    //                isDiureticSheet = false
                } else {
                    borderColor = Color.red
                }
            } else {
                borderColor = Color.red
            }
        }
                       , label: {
            Text("Create the custom drink")
        })
            .padding()
            .buttonStyle(LoginButton())
    }
    func createCustomDrink(name: String, isAlcohol: Bool, isCaffeine: Bool, amount: Double, alcoholAmount: Double, caffeineAmount: Double, alcoholPercentage: Double, isCustomWater: Bool, completionHandler: @escaping ((Bool, String)) -> ()) {
        //
        CustomDrinkDocument.addCustomDrink(newCustomDrink: CustomDrinkModel(id: CustomDrinkDocument.customDrinks.count, name: name, isAlcohol: isAlcohol, isCaffeine: isCaffeine, amount: amount, alcoholAmount: alcoholAmount, alcoholPercentage: alcoholPercentage, caffeineAmount: caffeineAmount, isCustomWater: isCustomWater), completionHandler: { isError, feedback in
            completionHandler((isError, feedback))
            
        })
    }
}
