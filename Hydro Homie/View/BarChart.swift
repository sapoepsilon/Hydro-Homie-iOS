//
//  BarChart.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/22/21.
//

import SwiftUI

struct BarView: View {
    @EnvironmentObject var user : UserDocument
    @State private var pickerSelectedItem = 0

    var currentLoop: Int = 0
    var body: some View {
    ZStack {
    Color(.orange).edgesIgnoringSafeArea(.all)
    VStack {
    Text("BAR CHART")
    .font(.system(size: 28))
    .fontWeight(.medium)
    .foregroundColor(Color(.white))
    Picker(selection: $pickerSelectedItem, label: Text("")) {
    Text("Weekly").tag(0)
    Text("Monthly").tag(1)
    Text("Yearly").tag(2)
    Text("Leap Year").tag(3)
    Text("Weekend").tag(4)
    }.pickerStyle(SegmentedPickerStyle())
    .padding(.horizontal, 24)
    HStack(spacing: 8) {
        
        ForEach(user.user.hydration, id: \.self) { hydration in
            BarChart(value: CGFloat(getChart(hydration: hydration).0), week: getChart(hydration: hydration).1)
        }
//
//        ForEach(getCupsData(), id: \.self) {cups in
//            BarChart(value: CGFloat(cups), week: "first Weel")
//        }
//    BarChart(value: dataPoints[pickerSelectedItem][0], week: "D")
//    BarChart(value: dataPoints[pickerSelectedItem][1], week: "D")
//    BarChart(value: dataPoints[pickerSelectedItem][2], week: "D")
//    BarChart(value: dataPoints[pickerSelectedItem][2], week: "D")
//    BarChart(value: dataPoints[pickerSelectedItem][2], week: "D")
    }.padding(.top, 24)
    .animation(.default)
           }
         }
      }
    func getChart(hydration: [String: Int]) -> (Int, String) {
        print(user.user.hydration)
        print(user.$user)

        var date: String = ""
        var cup: Int = 0
        for (dates,cups) in hydration {
            date = dates
            cup = cups
        }
        return (cup, date)
    }

    }


struct BarChart: View {
    var value: CGFloat = 0
    var week: String = ""
    var color = Color(red: 0.6, green: 0.6, blue: 0.6, opacity: 1)
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Capsule().frame(width: 40, height: value)
                    .foregroundColor(Color.orange)
                Capsule().frame(width: 30, height: value)
                    .foregroundColor(Color(.white))
                Capsule().frame(width: 30, height: value)
                    .foregroundColor(Color(.white))
                Capsule().frame(width: 20, height: value)
                    .foregroundColor(Color(.white))
                Capsule().frame(width: 20, height: value)
                    .foregroundColor(Color(.white))
            }
            Text(week).font(.headline   )
        }
    }
}
struct Preview: PreviewProvider {
    static var previews: some View {
        BarChart(value: 34, week: "Other week"  )
    }
}
