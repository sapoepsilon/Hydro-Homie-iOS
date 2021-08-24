//
//  BarChart.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/22/21.
//

import SwiftUI
import SwiftUICharts
import CoreLocation

struct BarView: View {
    @EnvironmentObject var user : UserDocument
    @State private var pickerSelectedItem = 0
    @State var waterColor: Color =  Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5)
    @State private var weekly: Bool = false
    @State private var cups: Double = 0
    @State private var weeklyOnAppear: Int = 0
    @State private var yearly: Bool = false
    @State private var monthly: Bool = false
    @State private var amountOfDays: Int = 0
    @State private var barData: [(String, Double)] = []
    @State private var barDataName: [String] = []
    @State private var barWidth: CGSize = CGSize(width: 400, height: 500)
    @State private var month: String = "January"
    @Environment(\.colorScheme) var colorScheme

    
    var currentLoop: Int = 0
    
    var style: ChartStyle {
        let st = Styles.barChartMidnightGreenLight
        st.textColor = .white
//                      st.textColor = .white
        st.backgroundColor = Color.white.opacity(0.6)
        st.darkModeStyle = Styles.barChartStyleNeonBlueDark
        st.gradientColor = GradientColor(start: waterColor, end: Color(red: 0, green: 0.5, blue: 0.85, opacity: 1))
        print(Styles.barChartMidnightGreenDark)
        st.darkModeStyle?.legendTextColor = Color.gray
        st.darkModeStyle?.backgroundColor = Color.clear
        st.darkModeStyle?.gradientColor = GradientColor(start: Color.white.opacity(0.3), end: Color.white.opacity(1))
        print(st.darkModeStyle?.accentColor.description as Any)
    
        return st
    }
    init() {
    UISegmentedControl.appearance().selectedSegmentTintColor = .white
       UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .selected)
       UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
    }
    var body: some View {
        ZStack {
            GeometryReader { geo in
//                ZStack{
//                    waterColor
//                        .opacity(0.8)
//                }
                ZStack {
                    VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
                        .edgesIgnoringSafeArea(.all )
                        waterColor.opacity(0.4)
                }
                
                VStack{
                    HStack(spacing: 0) {
                        Picker(selection: $pickerSelectedItem, label: Text("")) {
                        
                            Text("Last 7 days").foregroundColor(.white).tag(0)
                            Text(month).tag(1)
                            Text("Last 365 days").tag(2)

                        }
                        .onChange(of: pickerSelectedItem) { picker in
                                self.cups = 0
                                var counter: Int = 0
                                self.barData.removeAll()
                                if picker == 0 {
                                    weekly = true
                                    monthly = false
                                    
                                    for hydration in user.user.hydration {
                                        if (counter < 7 ) {
                                            withAnimation(.easeInOut) {
                                                self.amountOfDays = counter
                                                self.cups += getCups(hydration: hydration)

                                                barData.append(getDates(hydration: hydration))
                                            }
                                        }
                                        counter += 1
                                    }
                                }  else if picker == 1 {
                                    weekly = false
                                    monthly = true
                                    for hydration in user.user.hydration {
                                        if (counter < 30 ) {
                                            withAnimation(.easeInOut) {
                                                self.amountOfDays = counter
                                                self.cups += getCups(hydration: hydration)
                                                barData.append(getDates(hydration: hydration))
                                            }
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
                            .foregroundColor(colorScheme == .dark ? .white : .white)
                            .padding()
                        Spacer()
                    }
                    .padding()
                    
                    HStack{
                        Text("Total days: \(self.amountOfDays + 1)")
                            .foregroundColor(colorScheme == .dark ? .white : .white)
                            .padding()
                        Spacer()
                        
                    }
                    .padding()
                    Section {
                        // MARK: Barchart
                        ZStack {
//                            Rectangle()
//                                .frame(width: geo.size.width - 10, height: geo.size.height / 2)
//                                .foregroundColor(waterColor.opacity(0.4))
//                                .blur(radius: 3)
//                                .shadow(color: colorScheme == .dark ? Color.white : Color.black, radius: 10)
                            BarChartView(data: ChartData(values: barData), title: "Daily chart",legend: "Quarterely", style: style,  form: CGSize(width: geo.size.width - 10, height: geo.size.height / 2), dropShadow: true, animatedToBack: true)
                        }
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
            let monthInt = Calendar.current.component(.month, from: Date())
            month = Calendar.current.monthSymbols[monthInt - 1]
        }
        
    }
    
    func getCups(hydration: [String: Double]) -> Double {
        
        var cup: Double = 0
        for (_,cups) in hydration {
            cup += cups
        }
        return cup
    }
    
    func getDates(hydration: [String: Double]) -> (String, Double) {
        var cup: Double = 0
        var date: String = ""
        for (dates,cups) in hydration {
            date = dates
            cup += Double(cups)
        }
        return (date, cup)
    }
    
}
