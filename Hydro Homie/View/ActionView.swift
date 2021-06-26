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
        
        GeometryReader{ geometry in
            ZStack{
                Rectangle().foregroundColor(.white)
                VStack(alignment: .leading){
                    HStack{
                        Button(action: {
                            isStats = true
                        }, label: {
                            Text("Stats                                                    ")
                                .foregroundColor(.black)
                                .font(.system(size: geometry.size.height / 17))
                            Image(systemName: "chart.bar").foregroundColor(.green)
                                .scaleEffect(CGSize(width: 1.5, height: 1.5))

                        })
                    }
                    .padding()
                    //                .border(Color.green)
                    Text(" ")
                    HStack{
                        Button(action: {
                            isControl = true
                        }, label: {
                            Text("Precise control of hydration        ")
                                .foregroundColor(.black)
                                .font(.system(size: geometry.size.height / 17))
                            Image(systemName: "switch.2").foregroundColor(.blue)
                                .scaleEffect(CGSize(width: 1.5, height: 1.5))

                        })
                    }
                    .padding()
                    //                .border(Color.blue)
                    Text(" ")
                    HStack {
                        Button(action: {
                            isEdit = true
                        }, label: {
                            Text("Edit your Info                                    ")
                                .foregroundColor(.black)
                                .font(.system(size: geometry.size.height / 17))
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                                .scaleEffect(CGSize(width: 1.5, height: 1.5))
                        })
                    }
                    .padding()
                    //                .border(Color.blue)
                    
                    Text(" ")
                    HStack{
                        Button(action: {
                            
                        }, label: {
                            Text("How hydration is calculated       ")
                                .font(.system(size: geometry.size.height / 17))
                                .foregroundColor(.black)
                            Image(systemName: "info").foregroundColor(.blue)
                                .scaleEffect(CGSize(width: 1.5, height: 1.5))
                        })
                        
                    }
                    .padding()
                    //                .border(Color.blue)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
            .sheet(isPresented: self.$isEdit, content: {
                TextField(user.user.name, text: self.$userName)
                TextField(String(user.user.height), text: self.$userHeight)
            }
            )
            .sheet(isPresented: self.$isStats, content: {
                BarView().environmentObject(user)
            })
        }
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActionView(user: UserDocument())
//    }
//}
