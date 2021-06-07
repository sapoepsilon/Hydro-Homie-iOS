//
//  WaterView.swift
//  Hydro Homie
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
    
    @State private var waveOffset = Angle(degrees: 0)
    let percent: Int
    
    var body: some View {
        
        GeometryReader { geo in
            ZStack {
                Cup()
                    .stroke(Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5), lineWidth: /*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                    .foregroundColor(.clear)
                    .scaleEffect(0.92)
                    .overlay(
                        Wave(offset: Angle(degrees: self.waveOffset.degrees), percent: Double(percent)/100)
                            .fill(Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5))
                            .clipShape(Cup().scale(0.92))
                    )
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                self.waveOffset = Angle(degrees: 360)
            }
        }
     }
}

