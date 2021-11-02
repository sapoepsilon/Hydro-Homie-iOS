//
//  SwiftUIView.swift
//  Hydro Comrade
//
//  Created by Ismatulla Mansurov on 6/21/21.
//

import SwiftUI
import UIKit

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
    
    @Binding  var backgroundColorTop: Color
    @Binding  var backgroundColorBottom: Color
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
                    Spacer().frame(height: geometry.size.height / 4)
                    Text(" ")
                    HStack {
                        Button(action: {
                            isEdit = true
                        }, label: {
                            Text("Edit your info")
                                .foregroundColor(colorScheme == .dark ? Color.gray : Color.black)
                                .font(.system(size: fontSize))
                                .equalWidth()
                                .frame(width: width, alignment: .leading)
                            Image(systemName: "pencil")
                                .equalWidth()

                                .foregroundColor(.blue)
                                .scaleEffect(CGSize(width: 1.5, height: 1.5))
                        })
                    }
                    Spacer().frame(height: geometry.size.height / 4)
                    Text(" ")
                    HStack{
                        Button(action: {
                            let url = NSURL(string: "mailto:mailto:ismatullamansurov@gmail.com")
                            UIApplication.shared.open(url! as URL)
                            
                        }, label: {
                            Text("Contact the developer")
                                .foregroundColor(colorScheme == .dark ? Color.gray : Color.black)
                                .font(.system(size: fontSize))
                                .equalWidth()
                                .frame(width: width, alignment: .leading)
                            Image(systemName: "info").foregroundColor(.blue)
                                .equalWidth()

                                .scaleEffect(CGSize(width: 1.5, height: 1.5))
                        })
                        
                    }.padding()
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        Spacer().frame(height: geometry.size.height / 6)
                    }
                }
                .onPreferenceChange(WidthPreferenceKey.self) { widths in
                    if let width = widths.max() {
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            self.width = width * 1.4
                        }
                        print("width is :\(width)")
                    }
                }
                
            }
            .onAppear(perform: {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    fontSize = 50
                }
            })
//            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
         
        }
        .sheet(isPresented: self.$isEdit, content: {
            EditUserView(backgroundColorTop: $backgroundColorTop, backgroundColorBottom: $backgroundColorBottom, isMetric: $isMetric, isDashboard: $isEdit)
                .environmentObject(user)
        }
        )
        .fullScreenCover(isPresented: $isStats, content: {
                BarView(isStats: $isStats)
                    .clearModalBackground()
        })
    }
}




//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActionView(user: UserDocument())
//    }
//}
