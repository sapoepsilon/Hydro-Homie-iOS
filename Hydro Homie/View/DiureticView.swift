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
    @EnvironmentObject var customDrinkDocument: CustomDrinkViewModel
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
    @Binding var popUp: Bool
    @State private var isCustomCoffee: Bool = false
    
    //alcohol
    @Binding var isAlcoholConsumed:Bool
    @Binding var amountOfAccumulatedAlcohol: Double
    @Binding var percentageOfEachAlcohol: Double
    @Binding var amountOfEachAlcohol: Double
    
    //Coffee
    @Binding var coffeeAmount: Double
    @Binding var accumulatedCoffeeAmount: Double
    
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.gray.opacity(0.2)
                VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
            }
            VStack {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Spacer().frame(width: geometry.size.width, height: geometry.size.height / spacerAmount, alignment: .center)
                } else {
                    Spacer().frame(height: UIScreen.main.bounds.height / 30)
                }
                //MARK: Navigation of the diuretic view
                HStack {
                    Button(action: {
                        withAnimation() {
                            isCustomDrink = false
                            showCustomDrink = false
                            isCustomWater = false
                            isEdit = false
                        }
                        print("button pressed")
                    }, label: {
                        Image(systemName: "house")
                    })
                    .padding()
                    .opacity(isCustomDrink || isCustomWater || showCustomDrink ? 1 : 0)
                    
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
                        customDrinkDocument.getDrinkOpacity()
                        withAnimation() {
                            if isEdit {
                                isEdit = false
                            } else {
                                isDiuretic = false
                                isCustomWater = false
                                isCustomDrink = false
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
                    if !isCustomDrink && !showCustomDrink && !isCustomWater {
                        withAnimation() {
                            VStack {
                                VStack {
                                    HStack {
                                        Image(colorScheme == .dark ? "cupDark" : "cupLight")
                                            .renderingMode(.template)
                                            .foregroundColor(colorScheme == .light ? .white : .white)
                                    }
                                    .padding()
                                    
                                    Text ("Log a cup of water")
                                        .foregroundColor(colorScheme == .light ? .black : .white)
                                }.onTapGesture {
                                    cups += 1
                                    isDiuretic = false
                                }

                                .opacity(!isCustomDrink ? 1 : 0)
                                VStack {
                                    Image(colorScheme == .light ? "waterDrop" : "waterDropDark" )
                                            .renderingMode(.template)
                                            .foregroundColor(colorScheme == .light ? .white : .white)
                                        .padding()
                                    Text("Log custom amount of water")
                                        .foregroundColor(colorScheme == .light ? .black : .white)
                                }
                                .onTapGesture {
                                    withAnimation {
                                        isCustomWater = true
                                    }
                                }
                                VStack{
                                    Image("alcoholDark")
                                    Text("Your custom drinks")
                                        .foregroundColor(colorScheme == .light ? .black : .white)
                                }
                                .onTapGesture {
                                    withAnimation() {
                                        isCustomDrink = false
                                        showCustomDrink = true
                                    }
                                }
                                .padding()
                                
                                HStack {
                                    Button(action: {
                                        isCustomDrink = true
                                    }, label: {
                                        Text("Create a custom drink")
                                            .fontWeight(.bold)
                                    })
                                }
                                .padding()
                            }
                        }.transition(AnyTransition.move(edge: .bottom))
                    }
                }
                
                //MARK: Custom Water
                if showCustomDrink {
                    showCustomDrinks()
                        
                        .onAppear {
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                editIndent = geometry.size.width  - geometry.size.width / 1.4
                            } else  {
                                editIndent = geometry.size.width  - geometry.size.width / 2
                            }
                        }
                }
                if isCustomWater {
                    showCustomWater()
                        .transition(AnyTransition.move(edge: .bottom))
                        
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
            CustomDrink(isMetric: $isMetric, isCustomDrinkSheet: $isCustomDrink, isDiureticSheet: $isDiuretic)
                .environmentObject(customDrinkDocument)
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
                    Spacer().frame(width: 150)
                } else {
                    Spacer()
                }
                Text("Name: ")
                    //                    .frame(width: editIndent)
                    .font(Font.body.bold())
                Text("ALcohol in grams: ")
                    .frame(width: editIndent)
                    .font(Font.body.bold())
            }.onAppear {
                print("editIndent: \(editIndent)")
            }
            ForEach(customDrinkDocument.customDrinks, id: \.self) { drink in
                HStack() {
                    Group {
                        if drink.isAlcohol {
                            Image(colorScheme == .light ?  "alcohol" : "alcoholDark")
                                .renderingMode(.template)
                                .foregroundColor(colorScheme == .light ? .white : .white)
                                .padding()
                        } else if drink.isCaffeine {
                            Image(colorScheme == .light ?  "coffee" : "coffeeDark")
                                .foregroundColor(colorScheme == .light ? .white : .white)
                                .padding()
                        } else {
                            Image(colorScheme == .dark ? "waterDropDark" : "waterDrop")
                                .renderingMode(.template)
                                .foregroundColor(colorScheme == .light ? .white : .white)
                                .padding()
                        }
                    }
                    .onTapGesture {
                        cups += drink.amount
                        if drink.isAlcohol {
                            isAlcoholConsumed = true
                            self.amountOfAccumulatedAlcohol += drink.alcoholAmount
                            percentageOfEachAlcohol  = drink.alcoholPercentage
                        } else if drink.isCaffeine {
                            coffeeAmount = drink.caffeineAmount / 100
                            print("caffeine in .mg \(coffeeAmount)")
                        }
                        isDiuretic = false
                        popUp = false // close the .sheet and go back to the dashboard
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
                            } else if drink.isCaffeine {
                                coffeeAmount = drink.caffeineAmount / 1000
                                print("caffeine in .mg \(coffeeAmount)")
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
            }.opacity(showCustomDrink ? 1 : 0)
        }
        .transition(AnyTransition.move(edge: .bottom))
        
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
            }.opacity(isCustomWater ? 1 : 0)
        }
    }
    
    func spacerCaluclator() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 4.3
        } else {
            return 5
        }
    }
}


