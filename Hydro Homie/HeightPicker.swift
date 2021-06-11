//
//  HeightPicker.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/7/21.
//

import SwiftUI

struct HeightPicker: View {
    
    @State var foot: Int = 0
    @State var inch: Int = 0
    @State var meter: Int = 0
    @State var cm: Int = 0
    @State var measurement = ""
    
    @Binding var metric: Bool
    @Binding var height: Double
    
    var feet = [Int](0..<10)
    var inches = [Int](0..<12)
    var meters = [Int](0..<3)
    var cms = [Int](0..<100)
    
    var body: some View{
        VStack{
            GeometryReader() { geometry in
                HStack {
                    if !metric {
                        Picker(selection: self.$foot, label: Text("")) {
                            ForEach(0 ..< self.feet.count){ index in
                                Text("\(self.feet[index])").tag(self.feet[index])
                            }
                        }
                        
                        .onChange(of: foot) { _ in
                            self.height = Double(self.foot * 12 + self.inch)
                        }
                        .frame(width: geometry.size.width/4,height: geometry.size.height, alignment: .center)
                        .clipped()
                        .scaleEffect(CGSize(width: 1.0, height: 1.0))
                        .scaledToFit()
                        Text("\"")
                        
                        Picker(selection: self.$inch, label: Text("")) {
                            ForEach(0 ..< self.inches.count){ index in
                                Text("\(self.inches[index])").tag(self.inches[index])
                            }
                        }
                        .onChange(of: inch) { _ in
                            self.height = Double(self.foot * 12 + self.inch)
                        }
                        .frame(width: geometry.size.width/4,height: geometry.size.height, alignment: .center)
                        .clipped()
                        .scaleEffect(CGSize(width: 1.0, height: 1.0))
                        .scaledToFit()
                        Text("'")
                    } else {
                        Picker(selection: self.$meter, label: Text("")) {
                            ForEach(0 ..< self.meters.count){ index in
                                Text("\(self.meters[index])").tag(self.meters[index])
                            }
                        }
                        .onChange(of: self.meter) { _ in
                            self.height = Double(self.meter * 100 + self.cm)
                        }
                        .frame(width: geometry.size.width/4, height: geometry.size.height, alignment: .center)
                        .scaleEffect(CGSize(width: 1.0, height: 1.0))
                        .clipped()
                        .scaledToFit()
                        
                        Text("m")
                        
                        Picker(selection: self.$cm, label: Text("")) {
                            ForEach(0 ..< self.cms.count){ index in
                                Text("\(self.cms[index])").tag(self.cms[index])
                            }
                        }
                        .onChange(of: self.cm) { _ in
                            self.height = Double(self.meter * 100 + self.cm)
                        }
                        .frame(width: geometry.size.width/4,height: geometry.size.height, alignment: .center)
                        .clipped()
                        .scaleEffect(CGSize(width: 1.0, height: 1.0))
                        .scaledToFit()
                        
                        Text("cm")
                    }
                }
            }.frame(height: 45)
        }
        .frame(height: 45)
        .padding(.top,5)
        .padding(.bottom, 5)
    }
}

