//
//  BarChart.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/22/21.
//

import SwiftUI
import CoreLocation
import BarChart
import UIKit
import CareKitUI

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
    @State var currentPercentage: Double = 0
    
    var percentage: Double = 50
    var backgroundColor: Color = Color.gray
    var startColor: Color = Color(UIColor(red: 0, green: 0.5, blue: 0.75, alpha: 0.5))
    var endColor: Color = Color(UIColor.blue)
    var thickness: CGFloat = 10
    let config = ChartConfiguration()

    let selectionIndicatorHeight: CGFloat = 60
      @State var selectedBarTopCentreLocation: CGPoint?
      @State var selectedEntry: ChartDataEntry?
    
    let chartView = OCKCartesianChartView(type: .bar)
    @State var chartData: [OCKDataSeries] = [
        OCKDataSeries(values: [12,8,9,16,15,21,7,6,9,15,8,17,12,15,9], title: "Water", gradientStartColor: UIColor.blue, gradientEndColor:  UIColor(red: 0, green: 0.5, blue: 0.75, alpha: 0.5)),
    ]

    
    var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad ? true : false
    }

    var body: some View {
        
        ZStack {
        ZStack{
            waterColor
                .opacity(0.8)
        }
            ZStack {
                                VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
                                    .edgesIgnoringSafeArea(.all )
                                    waterColor.opacity(0.4)
                            }
        VStack {
            VStack(spacing: 10) {
                HStack {
                    Text("M")
                        .font(.title)
                        .padding(.bottom, isIpad ? 0 : -29)
                        .frame(width: UIScreen.main.bounds.width / 8.2)
                    Text("T")
                        .font(.title)
                        .padding(.bottom, isIpad ? 0 : -29)
                        .frame(width: UIScreen.main.bounds.width / 8.2)
                    Text("W")
                        .font(.title)
                        .padding(.bottom, isIpad ? 0 : -29)
                        .frame(width: UIScreen.main.bounds.width / 8.2)
                    Text("Th")
                        .font(.title)
                        .padding(.bottom, isIpad ? 0 : -29)
                        .frame(width: UIScreen.main.bounds.width / 8.2)
                    Text("F")
                        .font(.title)
                        .padding(.bottom, isIpad ? 0 : -29)
                        .frame(width: UIScreen.main.bounds.width / 8.2)
                    Text("S")
                        .font(.title)
                        .padding(.bottom, isIpad ? 0 : -29)
                        .frame(width: UIScreen.main.bounds.width / 8.2)
                    Text("Su")
                        .font(.title)
                        .padding(.bottom, isIpad ? 0 : -29)
                        .frame(width: UIScreen.main.bounds.width / 8.2)
                }
                HStack {
                    ringView(percentageWater: 0.8, startColor: Color.blue, endColor: Color(UIColor.blue), percentageAlcohol: 0.7, startColorAlcohol: Color.purple, endColorAlcohol: Color(UIColor.purple), percentageCoffee: 0.4, startColorCoffee: Color.orange, endColorCoffee: Color(UIColor.brown))
                        .shadow(color: .black, radius: 2, x: 0.0, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
                        .frame(width: UIScreen.main.bounds.width / 8.4)         .padding(.top)
                    
                    ringView(percentageWater: 0.5, startColor: Color.blue, endColor: Color(UIColor.blue), percentageAlcohol: 70, startColorAlcohol: Color.purple, endColorAlcohol: Color(UIColor.purple), percentageCoffee: 0.4, startColorCoffee: Color.orange, endColorCoffee: Color(UIColor.brown))
                        .shadow(color: .black, radius: 2, x: 0.0, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
                        .frame(width: UIScreen.main.bounds.width / 8.4)         .padding(.top)
                    
                    ringView(percentageWater: 1, startColor: Color.blue, endColor: Color(UIColor.blue), percentageAlcohol: 0.3, startColorAlcohol: Color.purple, endColorAlcohol: Color(UIColor.purple), percentageCoffee: 0.1, startColorCoffee: Color.orange, endColorCoffee: Color(UIColor.brown))
                        .shadow(color: .black, radius: 2, x: 0.0, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
                        .frame(width: UIScreen.main.bounds.width / 8.4)         .padding(.top)

                    ringView(percentageWater: 0.9, startColor: Color.blue, endColor: Color(UIColor.blue), percentageAlcohol: 70, startColorAlcohol: Color.purple, endColorAlcohol: Color(UIColor.purple), percentageCoffee: 0.9, startColorCoffee: Color.orange, endColorCoffee: Color(UIColor.brown))
                        .shadow(color: .black, radius: 2, x: 0.0, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
                        .frame(width: UIScreen.main.bounds.width / 8.4)         .padding(.top)
                    
                    ringView(percentageWater: 0.5, startColor: Color.blue, endColor: Color(UIColor.blue), percentageAlcohol: 70, startColorAlcohol: Color.purple, endColorAlcohol: Color(UIColor.purple), percentageCoffee: 0.4, startColorCoffee: Color.orange, endColorCoffee: Color(UIColor.brown))
                        .shadow(color: .black, radius: 2, x: 0.0, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
                        .frame(width: UIScreen.main.bounds.width / 8.4)         .padding(.top)

                    ringView(percentageWater: 0.5, startColor: Color.blue, endColor: Color(UIColor.blue), percentageAlcohol: 70, startColorAlcohol: Color.purple, endColorAlcohol: Color(UIColor.purple), percentageCoffee: 0.4, startColorCoffee: Color.orange, endColorCoffee: Color(UIColor.brown))
                        .shadow(color: .black, radius: 2, x: 0.0, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
                        .frame(width: UIScreen.main.bounds.width / 8.4)         .padding(.top)

                    ringView(percentageWater: 0.5, startColor: Color.blue, endColor: Color(UIColor.blue), percentageAlcohol: 70, startColorAlcohol: Color.purple, endColorAlcohol: Color(UIColor.purple), percentageCoffee: 0.9, startColorCoffee: Color.orange, endColorCoffee: Color(UIColor.brown))
                        .shadow(color: .black, radius: 2, x: 0.0, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
                        .frame(width: UIScreen.main.bounds.width / 8.4)         .padding(.top)
                }
                .frame(width: UIScreen.main.bounds.width * 0.95)
                .padding()
                
                
            }.frame(height: UIScreen.main.bounds.height / 5)
            Text("Today").frame(alignment: .top)
                .font(.title)
            mainRingView(percentageWater: 0.7, startColor: Color.blue, endColor: Color(UIColor.blue), percentageAlcohol: 0.2, startColorAlcohol: Color.orange, endColorAlcohol: Color(UIColor.purple), percentageCoffee: 0.5, startColorCoffee: Color.yellow, endColorCoffee: Color(UIColor.brown))
                .shadow(color: .blue.opacity(0.05), radius: 3, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
            VStack {
               
            }
            ZStack {
                Menu(content: {
                    Text("30 Days")
                    Text("1 Month")
                    Text("3 Months")
                    Text("6 Months")
                    Text("1 Year")
                }, label: {
                    Text("Time Period")
                }).zIndex(2)
                .offset(x: 120, y: -77)

                CartesianChartView(title: "Water", data: $chartData).frame(height:250)
                
                
            }.padding()
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
                    } else if counter > 7 && counter <= 30 {
                        withAnimation(.easeInOut) {
                            self.amountOfDays = counter
                            self.cups += getCups(hydration: hydration)
                            barData.append(getDates(hydration: hydration))
                        }
                    }
                    counter += 1
                }
            }
      
            let monthInt = Calendar.current.component(.month, from: Date())
            month = Calendar.current.monthSymbols[monthInt - 1]
        }
    }
 
    func createChart() {
        chartView.headerView.titleLabel.text = "Doxylamine"
        chartView.graphView.dataSeries = [
            OCKDataSeries(values: [12,8,9,16,15,21,7,6,9,15,8,17,12,15,9], title: "Water")
        ]
    }
    func ringView(percentageWater: Double, startColor: Color, endColor: Color, percentageAlcohol: Double, startColorAlcohol: Color, endColorAlcohol: Color, percentageCoffee: Double, startColorCoffee: Color, endColorCoffee: Color) -> some View {
        var thickness: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? 7 : 4 }
        var firstRingWidth: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width / 15 : UIScreen.main.bounds.width / 14}
        var firstRignHeight: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.height / 10 : UIScreen.main.bounds.height / 15}
        
        var secondRingWidth: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width / 11 : UIScreen.main.bounds.width / 9.7}
        var secondRignHeight: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.height / 13 : UIScreen.main.bounds.height / 14}
        
        var thirdRingWidth: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width / 8.7 : UIScreen.main.bounds.width / 7.2}
        var thirdRignHeight: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.height / 13 : UIScreen.main.bounds.height / 13}
        return            ZStack {
            RingView(
                percentage: percentageAlcohol,
                backgroundColor: Color.blue.opacity(0.3),
                startColor: Color.green,
                endColor: endColorAlcohol,
                thickness: thickness
            )
            .frame(width: firstRingWidth, height: firstRignHeight)
//            .aspectRatio(contentMode: .fit)
            RingView(
                percentage: percentageCoffee,
                backgroundColor: Color.blue.opacity(0.3),
                startColor: startColorCoffee,
                endColor: endColorCoffee,
                thickness: thickness
            )           .frame(width: secondRingWidth, height: secondRignHeight)
            .aspectRatio(contentMode: .fit)
            RingView(
                percentage: percentageWater,
                backgroundColor: Color.blue.opacity(0.3),
                startColor: startColor,
                endColor: endColor,
                thickness: thickness
            )
            .frame(width: thirdRingWidth, height: thirdRignHeight)
            .aspectRatio(contentMode: .fit)
        }
    }
    
    func mainRingView(percentageWater: Double, startColor: Color, endColor: Color, percentageAlcohol: Double, startColorAlcohol: Color, endColorAlcohol: Color, percentageCoffee: Double, startColorCoffee: Color, endColorCoffee: Color) -> some View {
        
        //MARK: first ring of the MAINRING
        var thickness: CGFloat {  UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.height / 22  : UIScreen.main.bounds.height / 40 }
        var firstRingWidth: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width / 4  : UIScreen.main.bounds.width / 4 }
        var firstRingHeight: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.height / 5  : UIScreen.main.bounds.height / 8 }
        //MARK: second ring of the MAINRING
      
        var secondRingWidth: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width / 2.55  : UIScreen.main.bounds.width / 2.7 }
        var secondRingHeight: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.height / 4  : UIScreen.main.bounds.height / 5 }
        //MARK: third ring of the MAINRING

        var thirdRingWidth: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width / 1.87  : UIScreen.main.bounds.width / 2.05}
        var thirdRingHeight: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.height / 2.5  : UIScreen.main.bounds.height / 4 }
        
        return ZStack {
            
            RingView(
                percentage: percentageAlcohol,
                backgroundColor: Color.blue.opacity(0.3),
                startColor: startColorAlcohol,
                endColor: endColorAlcohol,
                thickness: thickness
            )
            .frame(width: firstRingWidth, height: firstRingHeight)
            .aspectRatio(contentMode: .fit)
            RingView(
                percentage: percentageCoffee,
                backgroundColor: Color.blue.opacity(0.3),
                startColor: startColorCoffee,
                endColor: endColorCoffee,
                thickness: thickness
            )           .frame( width: secondRingWidth, height: secondRingHeight)
            .aspectRatio(contentMode: .fit)
            RingView(
                percentage: percentageWater,
                backgroundColor: Color.blue.opacity(0.3),
                startColor: startColor,
                endColor: endColor,
                thickness: thickness
            )
            .frame(width: thirdRingWidth, height: thirdRingHeight)
            .aspectRatio(contentMode: .fit)
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



//MARK: Ring shape
struct RingBackgroundShape: Shape {
    
    var thickness: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.width / 2, y: rect.height / 2),
            radius: rect.width / 2 - thickness,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 360),
            clockwise: false
        )
        return path
            .strokedPath(.init(lineWidth: thickness, lineCap: .round, lineJoin: .round))
    }
    
}

//MARK: Ring Shape
struct RingTipShape: Shape {
    
    var currentPercentage: Double
    var thickness: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let angle = CGFloat((360 * currentPercentage) * .pi / 180)
        let controlRadius: CGFloat = rect.width / 2 - thickness
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let x = center.x + controlRadius * cos(angle)
        let y = center.y + controlRadius * sin(angle)
        let pointCenter = CGPoint(x: x, y: y)
        
        path.addEllipse(in:
                            CGRect(
                                x: pointCenter.x - thickness / 2,
                                y: pointCenter.y - thickness / 2,
                                width: thickness,
                                height: thickness
                            )
        )
        
        return path
    }
    
    var animatableData: Double {
        get { return currentPercentage }
        set { currentPercentage = newValue }
    }
    
}

//MARK: Ring Shape
struct RingShape: Shape {
    
    var currentPercentage: Double
    var thickness: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.addArc(
            center: CGPoint(x: rect.width / 2, y: rect.height / 2),
            radius: rect.width / 2 - thickness,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 360 * currentPercentage),
            clockwise: false
        )
        
        return path
            .strokedPath(.init(lineWidth: thickness, lineCap: .round, lineJoin: .round))
    }
    
    var animatableData: Double {
        get { return currentPercentage }
        set { currentPercentage = newValue }
    }
    
}
//MARK: Ring View
struct RingView: View {
    
    @State var currentPercentage: Double = 0
    
    var percentage: Double
    var backgroundColor: Color
    var startColor: Color
    var endColor: Color
    var thickness: CGFloat
    
    var animation: Animation {
        Animation.easeInOut(duration: 1)
    }
    
    var body: some View {
        let gradient = AngularGradient(gradient: Gradient(colors: [startColor, endColor]), center: .center, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 360 * currentPercentage))
        return ZStack {
            RingBackgroundShape(thickness: thickness)
                .fill(backgroundColor)
            RingShape(currentPercentage: currentPercentage, thickness: thickness)
                .fill(gradient)
                .rotationEffect(.init(degrees: -90))
                .shadow(radius: 2)
                .drawingGroup()
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(self.animation) {
                            self.currentPercentage = self.percentage
                        }
                    }
                }
            RingTipShape(currentPercentage: currentPercentage, thickness: thickness)
                .fill(currentPercentage > 1 ? endColor : .clear)
                .rotationEffect(.init(degrees: -90))
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(self.animation) {
                            self.currentPercentage = self.percentage
                        }
                    }
                }
        }
        
    }
}


struct SampleView: View {
    
    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()
    
    // MARK: - Chart Properties
    
    let chartHeight: CGFloat = 300
    let config = ChartConfiguration()
    
    // MARK: - Selection Indicator
    
    let selectionIndicatorHeight: CGFloat = 60
    @State var selectedBarTopCentreLocation: CGPoint?
    @State var selectedEntry: ChartDataEntry?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
                    self.selectableChartView()
                    self.miniSelectableChartView()
                    Button(action: {
                        self.resetSelection()
                        self.config.data.entries = self.randomEntries()
                    }, label: {
                        Text("Random entries")
                    })
                    .onReceive(self.orientationChanged) { _ in
                        self.config.objectWillChange.send()
                        self.resetSelection()
                    }
                    .onAppear() {
                        // SwiftUI bug, onAppear is called before the view frame is calculated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            self.config.data.entries = self.randomEntries()
                            self.config.objectWillChange.send()
                        })
                    }
                    .navigationBarTitle(Text("SelectableBarChart"))
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Views
    
    func selectableChartView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            self.selectionIndicatorView()
            self.chartView()
        }
        .frame(height: chartHeight)
        .padding(15)
    }
    
    func miniSelectableChartView() -> some View {
        SelectableBarChartView<MiniSelectionIndicator>(config: self.config)
            .onBarSelection { entry, location in
                self.selectedBarTopCentreLocation = location
                self.selectedEntry = entry
            }
            .selectionView {
                MiniSelectionIndicator(entry: self.selectedEntry,
                                       location: self.selectedBarTopCentreLocation)
            }
            .frame(height: self.chartHeight - self.selectionIndicatorHeight)
            .padding(15)
    }
    
    func chartView() -> some View {
        GeometryReader { proxy in
            SelectableBarChartView<SelectionLine>(config: self.config)
                .onBarSelection { entry, location in
                    self.selectedBarTopCentreLocation = location
                    self.selectedEntry = entry
                }
                .selectionView {
                    SelectionLine(location: self.selectedBarTopCentreLocation,
                                  height: proxy.size.height - 17)
                }
        }
    }
    
    func selectionIndicatorView() -> some View {
        Group {
            if self.selectedEntry != nil && self.selectedBarTopCentreLocation != nil {
                SelectionIndicator(entry: self.selectedEntry!,
                                   location: self.selectedBarTopCentreLocation!.x,
                                   infoRectangleColor: Color(red: 241/255, green: 242/255, blue: 245/255))
            } else {
                Rectangle().foregroundColor(.clear)
            }
        }
        .frame(height: self.selectionIndicatorHeight)
    }
    
    func randomEntries() -> [ChartDataEntry] {
        var entries = [ChartDataEntry]()
        for data in 0..<15 {
            let randomDouble = Double.random(in: -20...50)
            let newEntry = ChartDataEntry(x: "\(2000+data)", y: randomDouble)
            entries.append(newEntry)
        }
        return entries
    }
    
    func resetSelection() {
        self.selectedBarTopCentreLocation = nil
        self.selectedEntry = nil
    }
}

struct SelectionIndicator: View {
    let entry: ChartDataEntry
    let location: CGFloat
    let infoRectangleColor: Color
    let infoRectangleWidth: CGFloat = 70
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: 3.0)
                    .foregroundColor(self.infoRectangleColor)
                VStack(alignment: .leading) {
                    HStack(alignment: .bottom, spacing: 2) {
                        Text("\(Int(self.entry.y))").font(.headline).fontWeight(.bold)
                        Text("b").font(.footnote)
                            .foregroundColor(.gray).fontWeight(.bold)
                    }
                    Text(self.entry.x)
                        .font(.footnote).foregroundColor(.gray).fontWeight(.bold)
                }
            }
            .frame(width: self.infoRectangleWidth)
            .offset(x: self.positionX(proxy, location: self.location))
            // '.id(UUID())' will prevent view from slide animation.
            .id(UUID())
        }
    }
    
    func positionX(_ proxy: GeometryProxy, location: CGFloat) -> CGFloat {
        let selectorCentre = self.infoRectangleWidth / 2
        let startX = location - selectorCentre
        if startX < 0 {
            return 0
        } else if startX + self.infoRectangleWidth > proxy.size.width {
            return proxy.size.width - self.infoRectangleWidth
        } else {
            return startX
        }
    }
}

struct SelectionLine: View {
    let location: CGPoint?
    let height: CGFloat
    let color = Color(red: 100/255, green: 100/255, blue: 100/255)

    var body: some View {
        Group {
            if location != nil {
                self.centreLine()
                    .stroke(lineWidth: 2)
                    .offset(x: self.location!.x)
                    .foregroundColor(self.color)
                    /* '.id(UUID())' will prevent view from slide animation.
                        Because this view is a child view and passed to 'BarChartView' parent, parent might already has animation.
                        So, If you want to disable it, just call '.animation(nil)' instead of '.id(UUID())' */
                    .id(UUID())
            }
        }
    }

    func centreLine() -> Path {
        var path = Path()
        let p1 = CGPoint(x: 0, y: 0)
        let p2 = CGPoint(x: 0, y: self.height)
        path.move(to: p1)
        path.addLine(to: p2)
        return path
    }
}

struct MiniSelectionIndicator: View {
    let entry: ChartDataEntry?
    let location: CGPoint?

    let height: CGFloat = 30
    let width: CGFloat = 40
    let spaceFromBar: CGFloat = 5
    let color: Color = Color(red: 230/255, green: 230/255, blue: 230/255)

    var body: some View {
        Group {
            if location != nil && self.entry != nil {
                ZStack {
                    RoundedRectangle(cornerRadius: 3.0)
                        .foregroundColor(self.color)
                    Text("\(Int(self.entry!.y))").font(.system(size: 12)).fontWeight(.bold)
                }
                .zIndex(1)
                .frame(width: self.width, height: self.height)
                .offset(x: self.location!.x - self.width / 2, y: self.location!.y - (self.height + self.spaceFromBar))
            }
        }
    }
}
struct CartesianChartView: UIViewRepresentable {
    var title: String
    var type: OCKCartesianGraphView.PlotType = .bar
    
    
    @Binding var data: [OCKDataSeries]
    
    func makeUIView(context: Context) -> OCKCartesianChartView {
        let chartView = OCKCartesianChartView(type: type)
        chartView.headerView.titleLabel.text = title
        chartView.graphView.dataSeries = data
        chartView.graphView.selectedIndex = 3
        
        return chartView
    }

    func updateUIView(_ uiView: OCKCartesianChartView, context: Context) {
        // will be called when bound data changed, so update internal
        // graph here when external dataset changed
        uiView.graphView.dataSeries = data
    }
}

