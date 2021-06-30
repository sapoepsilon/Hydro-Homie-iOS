//
//  PreciseControl.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/27/21.
//

import SwiftUI
import CoreLocation

struct PreciseControl: View {
    @State private var isWorkout: Bool = false
    @State private var workoutPicker = 0
    @StateObject var managerDelegate = locationService()
    @State private var locationManager = CLLocationManager()
    
    var body: some View {
        
        VStack {
            Toggle(isOn: self.$isWorkout, label: {
                Text("Do you workout?")
            })
            if isWorkout {
                
                HStack(spacing: 0) {
                    Picker(selection: $workoutPicker, label: Text("")) {
                        Text("30 min").tag(0)
                        Text("60 min").tag(1)
                        Text("90 min").tag(2)
                    }
                }
            }
        }
        .onAppear{
            withAnimation() {
                locationManager.delegate = managerDelegate
            }
            
        }
    }
}


struct PreciseControl_Previews: PreviewProvider {
    static var previews: some View {
        PreciseControl()
    }
}
