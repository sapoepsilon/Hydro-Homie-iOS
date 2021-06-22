//
//  SwiftUIView.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/21/21.
//

import SwiftUI

struct ActionView: View {
    @State private var isStats: Bool = false
    @State private var isControl: Bool = false
    @State private var isEdit: Bool = false
    @EnvironmentObject var user: UserDocument
    @State private var userName: String = ""
    @State private var userHeight: String = ""

    var body: some View {
        VStack(alignment: .leading){
                HStack{
                    Text("Stats                                          ").fontWeight(.heavy)
                    Image(systemName: "chart.bar").foregroundColor(.green).font(.subheadline)
                }
                .padding()
                .onTapGesture {
                    isStats = true
                    print(isStats)
                }
//                .border(Color.green)
                Text(" ")
                HStack{
                    Text("Precise control of hydration")
                    Image(systemName: "switch.2").foregroundColor(.blue)
                }
                .padding()
                .onTapGesture {
                    isStats = true
                    print(isStats)
                }
//                .border(Color.blue)
                Text(" ")
                
                HStack {
                    Text("Edit your Info                          ")
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
                .padding()
//                .border(Color.blue)
                .onTapGesture {
                    isEdit = true
                    print(isStats)
                }
                Text(" ")
                HStack{
                    Text("How hydration is calculated ")
                    Image(systemName: "info").foregroundColor(.blue)
                }
                .padding()
//                .border(Color.blue)
            
        }.sheet(isPresented: self.$isEdit, content: {
            TextField(user.user.name, text: self.$userName)
            TextField(String(user.user.height), text: self.$userHeight)
        })
        .sheet(isPresented: self.$isStats, content: {
            BarView().environmentObject(user)
        })
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActionView(user: UserDocument())
//    }
//}
