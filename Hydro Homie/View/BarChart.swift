//
//  BarChart.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/22/21.
//

import SwiftUI
import SwiftUICharts

struct BarView: View {
    @EnvironmentObject var user : UserDocument
    @State private var pickerSelectedItem = 0
    @State var waterColor: Color =  Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5)
    @State private var weekly: Bool = false
    @State private var cups: Int = 0
    @State private var weeklyOnAppear: Int = 0
    @State private var yearly: Bool = false
    @State private var monthly: Bool = false
    @State private var amountOfDays: Int = 0
    @State private var barData: [(String, Double)] = []
    @State private var barDataName: [String] = []
    @State private var barWidth: CGSize = CGSize(width: 400, height: 500) //delete later
    
    var currentLoop: Int = 0
    
    var style: ChartStyle {
        let st = Styles.barChartMidnightGreenLight
        st.textColor = .white
        st.backgroundColor = Color.white.opacity(0.6)
        st.darkModeStyle = Styles.barChartMidnightGreenDark
        st.darkModeStyle?.legendTextColor = Color.gray
//        st.darkModeStyle?.textColor = Color.white
//        st.darkModeStyle?.backgroundColor = waterColor

        return st
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                ZStack{
                    waterColor
                        .opacity(0.8)
                }
                .blur(radius: 8, opaque: false)
                
                VStack{
                    HStack(spacing: 0) {
                        Picker(selection: $pickerSelectedItem, label: Text("")) {
                            //TODO: Loop through each picker and determine the exact dates, and show the amount of cups drunken for that period. Optional: Add somekind of chart representation where the user can see the result by gliding.
                            Text("Last 7 days").tag(0)
                            Text("Last 30 days").tag(1)
                            Text("Last 365 days").tag(2)
                        }
                        .onChange(of: pickerSelectedItem) {picker in
                            self.cups = 0
                            var counter: Int = 0
                            self.barData.removeAll()
                            //after hovering the picker to equalize all the variables to zero
                            if picker == 0 {
                                weekly = true
                                monthly = false
                                
                                for hydration in user.user.hydration {
                                    //get the weekly report
                                    if (counter < 7 ) {
                                        self.amountOfDays = counter
                                        self.cups += getCups(hydration: hydration)
                                        barData.append(getDates(hydration: hydration))
                                        //                                            barDataName.append(getDates(hydration: hydration))
                                    }
                                    counter += 1
                                }
                            }  else if picker == 1 {
                                weekly = false
                                monthly = true
                                //get the monthly report
                                for hydration in user.user.hydration {
                                    if (counter < 30 ) {
                                        self.amountOfDays = counter
                                        self.cups += getCups(hydration: hydration)
                                        barData.append(getDates(hydration: hydration))
                                        //                                            barDataName.append(getDates(hydration: hydration))
                                    }
                                    counter += 1
                                }
                            } else {
                                monthly = false
                                weekly = false
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 24)
                    .animation(.default)
                    HStack{
                        Text("Total cups: \(self.cups)")
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                    }
                    .padding()
                    
                    HStack{
                        Text("Total days: \(self.amountOfDays)")
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                        
                    }
                    .padding()
                    Section {
                        BarChartView(data: ChartData(values: barData), title: "Daily chart",legend: "Legendary", style: style,  form: CGSize(width: geo.size.width - 10, height: geo.size.height / 2), dropShadow: true, animatedToBack: true)
                    }
                    Spacer()
                }
            }
        }.onAppear {
            //Count the stats on appear
            if weeklyOnAppear == 0 {
                weekly = true
                var counter: Int = 0
                for hydration in user.user.hydration {
                    if counter < 7 {
                        self.amountOfDays = counter
                        self.cups += getCups(hydration: hydration)
                        barData.append(getDates(hydration: hydration))
                    }
                    counter += 1
                }
            }
        }
        
    }
    
    func getCups(hydration: [String: Int]) -> Int {
        
        var cup: Int = 0
        for (dates,cups) in hydration {
            cup += cups
        }
        return cup
    }
    
    func getDates(hydration: [String: Int]) -> (String, Double) {
        var cup: Double = 0
        var date: String = ""
        for (dates,cups) in hydration {
            date = dates
            cup += Double(cups)
        }
        return (date, cup)
    }
    
}
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        BarView()
    }
}


