//
//  UserModel.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/9/21.
//

import Foundation

struct User: Encodable {
    var name: String
    var height: Int
    var weight: Double
    var metric: Bool
    var isCoffeeDrinker: Bool
    var waterIntake: Double
    var hydration: [[String: [String:Double]]]
    var userUID: String
}

