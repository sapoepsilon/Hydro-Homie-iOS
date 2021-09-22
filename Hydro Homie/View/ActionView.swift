//
//  SwiftUIView.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/21/21.
//

import SwiftUI
import CoreLocation

struct ActionView: View {
    @State private var isStats: Bool = false
    @State private var isEdit: Bool = false
    @EnvironmentObject var user: UserDocument
    @State private var userName: String = ""
    @State private var userHeight: String = ""
    @Environment(\.colorScheme) var colorScheme
    @State private var fontSize: CGFloat = 28
    @State private var width: CGFloat? = nil
    @State private var colorSCheme: ColorScheme = .light
    
    @Binding var isMetric: Bool

    var body: some View {
        GeometryReader{ geometry in
            ZStack {
                Rectangle()
                    .foregroundColor(colorScheme == .dark ?  Color.black.opacity(0.001) : Color.white.opacity(0.001))
            
                    VStack {
                        HStack{
                            Button(action: {
                                isStats = true
                            }, label: {
                                Text("Stats")
                                    .font(.system(size: fontSize))
                                    .foregroundColor(colorScheme == .dark ? Color.gray : Color.black)
                                    .equalWidth()
                                    .frame(width: width, alignment: .leading)
                                Image(systemName: "chart.bar").foregroundColor(.green)
                                    .equalWidth()
                                    .scaleEffect(CGSize(width: 1.5, height: 1.5))
                                    
                            })
                        }
                        Spacer()
                        Text(" ")
                        HStack {
                            Button(action: {
                                isEdit = true
                            }, label: {
                                Text("Edit your info")
                                    .foregroundColor(colorScheme == .dark ? Color.gray : Color.black)
                                    .equalWidth()
                                    .frame(width: width, alignment: .leading)
                                    .font(.system(size: fontSize))
                                
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                                    .scaleEffect(CGSize(width: 1.5, height: 1.5))
                            })
                        }
                        Spacer()
                        Text(" ")
                        HStack{
                            Button(action: {
                                
                            }, label: {
                                Text("How hydration is calculated")
                                    .foregroundColor(colorScheme == .dark ? Color.gray : Color.black)
                                    .equalWidth()
                                    .font(.system(size: fontSize))
                                    .frame(width: width, alignment: .leading)
                                Image(systemName: "info").foregroundColor(.blue)
                                    .scaleEffect(CGSize(width: 1.5, height: 1.5))
                            })
                            
                        }.padding()
                    }
                    .onPreferenceChange(WidthPreferenceKey.self) { widths in
                                    if let width = widths.max() {
                                        self.width = width
                                    }
                                }
            }
            .onAppear(perform: {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    fontSize = 50
                }
            })
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
            .sheet(isPresented: self.$isEdit, content: {
                EditUserView(isMetric: $isMetric, isDashboard: $isEdit)
                    .environmentObject(user)
//                TextField(user.user.name, text: self.$userName)
//                TextField(String(user.user.height), text: self.$userHeight)
            }
            )
            .formSheet(isPresented: self.$isStats, content: {
                BarView().environmentObject(user)
                    .clearModalBackground()
            })
        }
        
    }
}




//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActionView(user: UserDocument())
//    }
//}
