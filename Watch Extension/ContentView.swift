//
//  ContentView.swift
//  Watch Extension
//
//  Created by Ismatulla Mansurov on 7/28/21.
//

import SwiftUI

struct ContentView: View {
    @State private var waterFactor: Double = 40
    @State private var waterColor: Color = Color( red: 1, green: 0.5, blue: 1, opacity: 1)
    var body: some View {
        WaterView(factor: $waterFactor, waterColor: $waterColor)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
