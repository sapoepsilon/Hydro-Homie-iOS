//
//  SwiftUIView.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/21/21.
//

import SwiftUI

struct ActionView: View {
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Text("Stats                                       ")
                Image(systemName: "chart.bar").foregroundColor(.green)
            }
            Text(" ")
            HStack{
                Text("Precise control of hydration")
                Image(systemName: "switch.2").foregroundColor(.blue)
            }
            Text(" ")

            HStack {
                Text("Edit your Info                          ")
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
            Text(" ")
            HStack{
                Text("How hydration is calculated ")
                Image(systemName: "info").foregroundColor(.blue)
                
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ActionView()
    }
}
