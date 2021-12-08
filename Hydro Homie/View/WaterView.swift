//
//  WaterView.swift
//  Hydro Comrade
//
//  Created by Ismatulla Mansurov on 6/6/21.
//

import SwiftUI


struct Wave: Shape {

    var offset: Angle
    var percent: Double
    
    var animatableData: Double {
        get { offset.degrees }
        set { offset = Angle(degrees: newValue) }
    }
    
    func path(in rect: CGRect) -> Path {
        var p = Path()

        // empirically determined values for wave to be seen
        // at 0 and 100 percent
        let lowfudge = 0.02
        let highfudge = 0.98
        
        let newpercent = lowfudge + (highfudge - lowfudge) * percent
        let waveHeight = 0.015 * rect.height
        let yoffset = CGFloat(1 - newpercent) * (rect.height - 4 * waveHeight) + 2 * waveHeight
        let startAngle = offset
        let endAngle = offset + Angle(degrees: 360)
        
        p.move(to: CGPoint(x: 0, y: yoffset + waveHeight * CGFloat(sin(offset.radians))))
        
        for angle in stride(from: startAngle.degrees, through: endAngle.degrees, by: 5) {
            let x = CGFloat((angle - startAngle.degrees) / 360) * rect.width
            p.addLine(to: CGPoint(x: x, y: yoffset + waveHeight * CGFloat(sin(Angle(degrees: angle).radians))))
        }
        
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: rect.height))
        p.closeSubpath()
        
        return p
    }
}

struct Cup: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minX))
        
        path.addQuadCurve(to: CGPoint(x: rect.size.width/2, y: rect.size.height), control: CGPoint(x: rect.size.width, y: rect.size.height))
        path.addQuadCurve(to: CGPoint(x: rect.size.width/2, y: 0), control: CGPoint(x: 0, y: rect.size.height))
        
        return path
    }
}

struct WaterView: View {
    
//    @State private var show: Bool = false
//    @State var offset: Angle = Angle(degrees: 0)
//    @Binding var factor: Double
    @Environment(\.colorScheme) var colorScheme
//    @State private var percent: Double = 0
    @State var offset:Angle = Angle.degrees(0)
    @State private var wave: Double = 1

    let factor: Double
    @Binding var waterColor: Color

    @Binding var backgroundColor: Color
    @ObservedObject var displayLink = DisplayLink.sharedInstance


        var body: some View {
            GeometryReader { proxy in
                ZStack {
                    Cup()
                        .stroke(colorScheme == .light ? Color.gray : Color.gray , lineWidth: 0.0025 * min(proxy.size.width, proxy.size.height))
                        .overlay(
                            backgroundColor
                                .clipShape(Cup())
                        )
                        .overlay(
                            Wave( offset: self.offset, percent: factor / 100 )
                                .fill(waterColor)
                                .opacity(0.6)
                                .blur(radius: 1.5, opaque: false)
                                .clipShape(Cup())
                        )
                        .onChange(of: colorScheme, perform: {_ in
                            if colorScheme == .light {
                                waterColor = Color( red: 0, green: 0.5, blue: 0.7, opacity: 1)
                            } else {
                                waterColor = Color( red: 0, green: 0.5, blue: 0.8, opacity: 1)
                            }
                        })
                        .onAppear {
                            withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                                self.offset = Angle(degrees: 360)
                            }
                            if(colorScheme == .light) {
                                //                            UIToolbar.appearance().barTintColor = .clear
                            }
                        }
                }
            }.aspectRatio(1, contentMode: .fit)
               .onReceive(displayLink.$frameChange, perform: { _ in
                   self.offset.degrees += wave
                                        }
                                 )
               .onChange(of: self.offset, perform: { _ in
                   if self.offset.degrees >= 720 { wave = -1 } else if self.offset.degrees <= 0 { wave = 1}
                   
               })
           
       }//    @State private var wave: Double = 1
        
    //
//    var body: some View {
//        GeometryReader { proxy in
//            ZStack {
//                Cup()
//                    .stroke(colorScheme == .light ? Color.gray : Color.gray , lineWidth: 0.0025 * min(proxy.size.width, proxy.size.height))
//                    .overlay(
//                        backgroundColor
//                            .clipShape(Cup())
//                    )
//                    .overlay(
//                        Wave( offset: self.offset, percent: factor / 100 )
//                            .fill(waterColor)
//                            .opacity(0.6)
//                            .blur(radius: 1.5, opaque: false)
//                            .clipShape(Cup())
//                    )
//                    .onChange(of: colorScheme, perform: {_ in
//                        if colorScheme == .light {
//                            waterColor = Color( red: 0, green: 0.5, blue: 0.7, opacity: 1)
//                        } else {
//                            waterColor = Color( red: 0, green: 0.5, blue: 0.8, opacity: 1)
//                        }
//                    })
//                    .onAppear {
//                        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
//                            self.offset = Angle(degrees: 360)
//                        }
//                        if(colorScheme == .light) {
//                            //                            UIToolbar.appearance().barTintColor = .clear
//                        }
//                        show = true
//                    }
//            }
            //            .onReceive(displayLink.$frameChange, perform: { _ in
            //
            //                        if self.offset.degrees > 358 {
            //                            wave = -0.75
            //                        } else if self.offset.degrees < 2 {
            //                            wave = 0.75
            //                        }
            //
            //                        if self.offset.degrees < 360 {
            //                                self.offset.degrees += wave
            //                        }
            //
            //                        if percent < factor {
            //                            percent += 1
            //                        } else if (percent > factor) {
            //                            percent -= 1
            //                            }
            //                        }
            //                    )
//        }        .aspectRatio(1, contentMode: .fit)
//    }
    
    
}
//struct ContentView_Previews: PreviewProvider {
//    @State static private var offset = Angle(degrees: 0)
//    @State static private var color = Color.blue
//    static var previews: some View {
//        WaterView(offset: $offset, factor: 52, waterColor: $color, backgroundColor: $color)
//            .onAppear {
//                withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
//                self.offset = Angle(degrees: 360)
//                }
//            }
//    }
//}
