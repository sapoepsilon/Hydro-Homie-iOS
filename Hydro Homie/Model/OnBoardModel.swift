//
//  OnBoardModel.swift
//  Hydro Comrade
//
//  Created by Ismatulla Mansurov on 11/6/21.
//

import SwiftUI

struct OnBoardModel: Identifiable {
    var id = UUID().uuidString
    var title: String
    var subtitle: String
    var description: String
    var pic: (String, String?)
    var color: Color
    var offset: CGSize = .zero
}
