//
//  DiureticView.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/28/21.
//

import SwiftUI

struct DiureticView: View {
    
    @State private var customCoffeeName: String = ""
    @Binding var cups: Double
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var customDrinkDocument: CustomDrinkViewModel
    @State private var scaleEffect: CGFloat = 1
    @State private var spacerAmount: CGFloat = 0
    @Binding var waterColor: Color
    @State private var editIndent: CGFloat = 0
    
    //Booleans
    @Binding var isCustomWater: Bool
    @Binding var isMetric:Bool
    @Binding var isDiuretic: Bool
    @State private var isEdit = false
    @State private var showCustomDrink: Bool = false
    @State private var isCustomDrink: Bool = false
    @State private var isAlcohol: Bool = false
    @Binding var popUp: Bool
    @State private var isCustomCoffee: Bool = false
    @State private var isCoffee: Bool = false
    
    //alcohol
    @Binding var isAlcoholConsumed:Bool
    @Binding var amountOfAccumulatedAlcohol: Double
    @Binding var percentageOfEachAlcohol: Double
    @Binding var amountOfEachAlcohol: Double
    
    
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.gray.opacity(0.2)
                VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
            }
            ScrollView {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Spacer().frame(width: geometry.size.width, height: geometry.size.height / spacerAmount, alignment: .center)
                }
                
                HStack {
                    Button(action: {
                        withAnimation() {
                            isCoffee = false
                            isAlcohol = false
                            isCustomDrink = false
                            showCustomDrink = false
                            isCustomWater = false
                            isEdit = false
                        }
                    }, label: {
                        Image(systemName: "chevron.backward")
                    })
                    .opacity(isCoffee || isAlcohol || isCustomDrink || isCustomWater || showCustomDrink ? 1 : 0)
                    .padding()
                    
                    Spacer().frame(width: geometry.size.width / spacerCaluclator())
                    
                    Button(action: {
                        customDrinkDocument.fetchFromServer()
                    }, label: {
                        if !isEdit {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(Angle(degrees: 90))
                        }
                    }).opacity(showCustomDrink || isCustomWater ? 1 : 0)
                    
                    Button(action: {
                            isEdit.toggle()
                        
                    }, label: {
                        Image(systemName: "pencil")
                    }).opacity(showCustomDrink || isCustomWater ? 1 : 0)
                    
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
                    if !isCoffee && !isAlcohol && !isCustomDrink && !showCustomDrink && !isCustomWater {
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            if UIDevice().type == .iPhone8 {
                                
                            } else {
                                
                            }
                        }
                            VStack {
                                HStack {
                                    Image(colorScheme == .dark ? "waterDropDark" : "waterDrop")
                                        .renderingMode(.template)
                                        .foregroundColor(colorScheme == .light ? .white : .white)
                                }
                                .padding()
                                
                                Text ("Log a cup of Water")
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
                            }
                            .padding()
                            .onTapGesture {
                                withAnimation {
                                    isCustomWater = true
                                }
                            }
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
                            
                            HStack {
                                Button(action: {
                                    isCustomDrink = true
                                    isCoffee = false
                                    isAlcohol = false
                                }, label: {
                                    Text("Add a custom drink")
                                        .fontWeight(.bold)
                                })
                            }
                            .padding()
                            
                        }
                    
                    //MARK: Coffee
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
                    //MARK: Alcohol
                    
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
                
                //MARK: Custom Water
                if isCustomWater {
                    showCustomWater()
                        
                        .onAppear {
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                editIndent = geometry.size.width  - geometry.size.width / 1.4
                            } else  {
                                editIndent = geometry.size.width  - geometry.size.width / 2
                            }
                        }
                } else {
                    showCustomDrinks()
                        .onAppear {
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                editIndent = geometry.size.width  - geometry.size.width / 1.4
                            } else  {
                                editIndent = geometry.size.width  - geometry.size.width / 2
                            }
                        }
                }
                //                }
                //                //MARK: Custom Drink
                
                
            }
            .frame(width: geometry.size.width - 10)
        }
        .scaleEffect(scaleEffect)
        .onAppear {
            if UIDevice.current.userInterfaceIdiom == .pad {
                scaleEffect = 1.5
                spacerAmount = 5.8
                
            }
            print("Model name: \(UIDevice().type )")
            
        }
        .sheet(isPresented: $isCustomDrink, content: {
            CustomDrink(CustomDrinkDocument: CustomDrinkViewModel(), isMetric: $isMetric, isCustomDrinkSheet: $isCustomDrink, isDiureticSheet: $isDiuretic)
        })
        .sheet(isPresented: $isCustomCoffee, content: {
            TextField("Name of the coffee", text:
                        $customCoffeeName)
        })
        Spacer()
    }
    
    func showCustomDrinks() -> some View {
        VStack(alignment: .leading) {
            HStack() {
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Spacer().frame(width: 130)
                } else {
                    Spacer().frame(width: editIndent)
                }
                Text("Drinks: ")
                    .font(Font.body.bold())
                Text("Alcohol in gm: ")
                    .frame(width: editIndent)
                    .font(Font.body.bold())
            }.opacity(showCustomDrink ? 1 : 0)
            
            ForEach(customDrinkDocument.customDrinks, id: \.self) { drink in
                HStack() {
                    if drink.isAlcohol {
                        Image(colorScheme == .light ?  "alcohol" : "alcoholDark")
                            .renderingMode(.template)
                            .foregroundColor(colorScheme == .light ? .white : .white)
                    } else if drink.isCaffeine {
                        Image(colorScheme == .light ?  "coffee" : "coffeeDark")
                    } else {
                        Image(colorScheme == .dark ? "waterDropDark" : "waterDrop")
                            .renderingMode(.template)
                            .foregroundColor(colorScheme == .light ? .white : .white)
                    }
                    
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
                .onLongPressGesture {
                    withAnimation {
                        isEdit = true
                    }
                    
                }
            }
        }.opacity(showCustomDrink ? 1 : 0)
    }
    
    func showCustomWater() -> some View {
        VStack(alignment: .leading) {
            HStack() {
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Spacer().frame(width: 150)
                } else {
//                    padding(.horizontal, 20)
                }
                Text("Name: ")
//                    .frame(width: editIndent)
                    .font(Font.body.bold())
                Text("Amount of cups: ")
                    .frame(width: editIndent)
                    .font(Font.body.bold())
            }.onAppear {
                print("editIndent: \(editIndent)")
            }
            
            ForEach(customDrinkDocument.customDrinks, id: \.self) { drink in
                if drink.isCustomWater {
                    HStack() {

                        Image(colorScheme == .dark ? "waterDropDark" : "waterDrop")
                            .renderingMode(.template)
                            .foregroundColor(colorScheme == .light ? .white : .white)
                            .onTapGesture {
                                cups += drink.amount
                                isDiuretic = false
                                popUp = false // close the .sheet and go back to the dashboard
                            }
                            .padding()
                        
                        Text(drink.name)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                            .padding()
                            .onTapGesture {
                                cups += drink.amount
                                isDiuretic = false
                                popUp = false // close the .sheet and go back to the dashboard
                            }
                            .frame(width: editIndent)
                
                        let formattedFloat = String(format: "%.1f", drink.amount)
                        Text(formattedFloat)
                        
                        Button(action: {
                            customDrinkDocument.deleteCustomDrink(customDrink: drink)
                        }, label: {
                            Image(systemName: "minus.circle")
                        }).opacity(isEdit ? 1 : 0)
                        .foregroundColor(.red)
                    }
                    .onLongPressGesture {
                        withAnimation {
                            isEdit = true
                        }
                    }
                }
            }
        }.opacity(isCustomWater ? 1 : 0)
        
    }
    
    func spacerCaluclator() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 4.3
        } else {
            return 5
        }
    }
}


