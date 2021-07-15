//
//  CustomDrinkModel.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 7/10/21.
//

import Foundation

struct CustomDrinkModel: Hashable, Codable {
    var id: Int
    var name: String
    var isAlcohol: Bool
    var isCaffeine: Bool
    var amount: Double
//    var amountOfAlcohol: Double?

}



