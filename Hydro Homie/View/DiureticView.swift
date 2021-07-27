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
    @ObservedObject var customDrinkDocument: CustomDrinkViewModel
    @State private var isCustomDrink: Bool = false
    @State private var scaleEffect: CGFloat = 1
    @State private var spacerAmount: CGFloat = 0
    @State private var showCustomDrink: Bool = false
    @Binding var waterColor: Color
    @State private var isEdit = false
    @State private var editIndent: CGFloat = 0
    @Binding var isMetric:Bool
    
    //alcohol
    @Binding var isAlcoholConsumed:Bool
    @Binding var amountOfAccumulatedAlcohol: Double
    @Binding var percentageOfEachAlcohol: Double
    @Binding var amountOfEachAlcohol: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.gray.opacity(0.7)
                VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
            }
            ScrollView {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Spacer().frame(width: geometry.size.width, height: geometry.size.height / spacerAmount, alignment: .center)
                }
                HStack {
                    
                    Button(action: {
                        isCoffee = false
                        isAlcohol = false
                        isCustomDrink = false
                        showCustomDrink = false
                        isEdit = false
                    }, label: {
                        Image(systemName: "chevron.backward")
                    })
                    .opacity(isCoffee || isAlcohol || isCustomDrink || showCustomDrink ? 1 : 0)
                    .padding()
                    
                    Spacer().frame(width: geometry.size.width / spacerCaluclator())

                    Button(action: {
                        withAnimation() {
                            isEdit.toggle()
                        }
                    }, label: {
                        Image(systemName: "pencil")
                    }).opacity(showCustomDrink == true ? 1 : 0)
                    
                    Button(action: {
                        customDrinkDocument.fetchFromServer()
                    }, label: {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(Angle(degrees: 90))
                    })
                        .opacity(showCustomDrink == true ? 1 : 0)
                    
                    Spacer().frame(width: geometry.size.width / spacerCaluclator())

                    
                    Button(action: {
                        withAnimation() {
                            if isEdit {
                                isEdit = false
                            } else {
                                isDiuretic = false
                            }
                        }
                    }, label: {
                        if isEdit {
                            Text("Done Editing")
                        } else {
                            Text("Done")
                        }
                    })
                    .padding(.horizontal, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                }
                VStack {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        if showCustomDrink {
                            
                            if UIDevice.current.modelName == "iPhone8,4" || UIDevice.current.modelName == "iPhone9,1" || UIDevice.current.modelName == "iPhone9,2" || UIDevice.current.modelName == "iPhone10,1" ||  UIDevice.current.modelName == "iPhone10,2" || UIDevice.current.modelName == "iPhone10,5" {

                        }
                        else {
                            Spacer().frame(width: geometry.size.width, height: geometry.size.height / 6	, alignment: .center)
                            }
                        }
                    }
                    
                    if !isCoffee && !isAlcohol && !isCustomDrink && !showCustomDrink {
                        VStack {
                            VStack {
                                HStack {
                                    Image(colorScheme == .dark ? "waterDropDark" : "waterDrop")
                                        .renderingMode(.template)
                                        .foregroundColor(colorScheme == .light ? .white : .white)
                                }
                                .padding()
                                
                                Text ("Log Water")
                                    .foregroundColor(colorScheme == .light ? .black : .white)
                            }.onTapGesture {
                                cups += 1
                                isDiuretic = false
                            }
                            VStack {
                                HStack{
                                    Image(colorScheme == .light ?  "coffee" : "coffeeDark")
                                        .renderingMode(.template)
                                        .foregroundColor(colorScheme == .light ? .white : .white)
                                }
                                .padding()
                                Text("Log Coffee")
                                    .foregroundColor(colorScheme == .light ? .black : .white)
                            }
                            .onTapGesture {
                                withAnimation() {
                                    isCustomDrink = false
                                    isAlcohol = false
                                    isCoffee = true
                                    print(isCoffee)
                                }
                            }
                            .opacity(!isCoffee || !isAlcohol || !isCustomDrink ? 1 : 0)
                            VStack {
                                HStack{
                                    Image(colorScheme == .light ?  "alcohol" : "alcoholDark")
                                        .renderingMode(.template)
                                        .foregroundColor(colorScheme == .light ? .white : .white)
                                }
                                .padding()
                                
                                Text("Log Alcohol")
                                    .foregroundColor(colorScheme == .light ? .black : .white)
                            }
                            .onTapGesture {
                                withAnimation() {
                                    isCustomDrink = false
                                    isCoffee = false
                                    isAlcohol = true
                                }
                            }
                            .opacity(!isCoffee || !isAlcohol || !isCustomDrink ? 1 : 0)
                            HStack {
                                Text("Log custom amount of water")
                                    .foregroundColor(colorScheme == .light ? .black : .white)
                            }.padding()
                            HStack{
                                Text("Your custom drinks")
                                    .fontWeight(.bold)
                                    .foregroundColor(colorScheme == .light ? .black : .white)
                            }
                            .onTapGesture {
                                withAnimation() {
                                    isCustomDrink = false
                                    isCoffee = false
                                    isAlcohol = false
                                    showCustomDrink = true
                                }
                            }
                            .padding()
//                            if UIDevice.current.modelName == "iPhone13,1" || UIDevice.current.modelName == "iPhone13,2" || UIDevice.current.modelName == "iPhone13,3" || UIDevice.current.modelName == "iPhone13,4" {
//                                Spacer().frame(height: geometry.size.height / 6)
//                            } else if UIDevice.current.modelName == "iPhone8,4" || UIDevice.current.model == "iPhone10,1" || UIDevice.current.model == "iPhone10,4" || UIDevice.current.model == "iPhone7,2" || UIDevice.current.model == "iPhone7,1" || UIDevice.current.model == "iPhone8,1" || UIDevice.current.model == "iPhone8,2" {
//                                Spacer().frame(height: geometry.size.height / 14)
//                            }
//                            else {
//                                Spacer().frame(height: geometry.size.height / 11)
//                            }
                            HStack {
                                Text("Add a custom Drink")
                                    .fontWeight(.bold  )
                                    .foregroundColor(.blue)
                            }
                            .onTapGesture {
                                withAnimation() {
                                    isCustomDrink = true
                                    isCoffee = false
                                    isAlcohol = false
                                }
                            }
                            .padding()
                            
                        }
                    }
                    if isCoffee  {
                        Text("Black coffee").padding()
                            .onTapGesture {
                                cups += 0.5
                                isDiuretic = false
                                popUp = false // close the popUp for the popUp view
                                print("black coffee \(cups)")
                            }
                            .foregroundColor(colorScheme == .light ? .black : .white)
                        
                        Text("Decaf coffee").padding()
                            .onTapGesture {
                                cups += 0.95
                                isDiuretic = false
                                popUp = false // close the popUp for the popUp view
                                print("decaf coffee \(cups)")
                                
                            }
                            .foregroundColor(colorScheme == .light ? .black : .white)
                        
                        Text("Starbucks coffees").padding()
                            .foregroundColor(colorScheme == .light ? .black : .white)
                        
                        Text("Add custom coffee").padding()
                            .foregroundColor(colorScheme == .light ? .black : .white)
                            .onTapGesture {
                                isCustomDrink = true
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
                            .foregroundColor(colorScheme == .light ? .black : .white)
                        
                        Text("Wine 9%").padding()
                            .onTapGesture {
                                cups += 0.8
                                isDiuretic = false
                                popUp = false // close the popUp for the popUp view
                                print("wine 9%  \(cups)")
                            }
                            .foregroundColor(colorScheme == .light ? .black : .white)
                        
                        Text("Beer 5%").padding()
                            .onTapGesture {
                                cups += 0.85
                                isDiuretic = false
                                popUp = false // close the popUp for the popUp view
                                print("wine Beer 5%  \(cups)")
                            }
                            .foregroundColor(colorScheme == .light ? .black : .white)
                        
                        Text("Beer 4%").padding()
                            .onTapGesture {
                                cups += 0.9
                            }
                            .foregroundColor(colorScheme == .light ? .black : .white)
                    }
                }
                // Show each drink's name and alcohol amount
                
                HStack {
                    Text("Drink's name: ")
                        .frame(width: editIndent)
                    Text("Alcohol amount in gm: ")
                }.opacity(showCustomDrink ? 1 : 0)
                
                ForEach(customDrinkDocument.customDrinks, id: \.self) { drink in
                    HStack(alignment: .center) {
                        Text(drink.name)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                            .padding()
                            .onTapGesture {
                                cups += drink.amount
                                isDiuretic = false
                                popUp = false // close the .sheet and go back to the dashboard
                                if drink.isAlcohol {
                                    isAlcoholConsumed = true
                                    self.amountOfAccumulatedAlcohol += drink.alcoholAmount
                                    percentageOfEachAlcohol  = drink.alcoholPercentage
                                }
                            }
                            .frame(width: editIndent)
                        let formattedFloat = String(format: "%.1f", drink.alcoholAmount)
                        Text(formattedFloat)
                        Button(action: {
                            customDrinkDocument.deleteCustomDrink(customDrink: drink)
                        }, label: {
                            Image(systemName: "minus.circle")	
                        }).opacity(isEdit ? 1 : 0)
                            .foregroundColor(.red)
                    }
                }
                .onAppear {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        editIndent = geometry.size.width  - geometry.size.width / 2.4
                    } else  {
                        editIndent = geometry.size.width  - 60
                    }
                }
                .opacity(showCustomDrink ? 1 : 0)
            }
            .frame(width: geometry.size.width - 10)
        }
        .scaleEffect(scaleEffect)
        .onAppear {
            if UIDevice.current.userInterfaceIdiom == .pad {
                scaleEffect = 1.5
                spacerAmount = 5.8
            }
        }
        
        .sheet(isPresented: $isCustomDrink, content: {
            CustomDrink(CustomDrinkDocument: CustomDrinkViewModel(), isMetric: $isMetric)
        })
        .sheet(isPresented: $isCustomCoffee, content: {
            TextField("Name of the coffee", text:
                        $customCoffeeName)
        })
        Spacer()
    }
    
    func spacerCaluclator() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 4.1
        } else {
            return 3.4
        }
    }
    
    
}


