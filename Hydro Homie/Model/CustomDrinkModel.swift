

//
//  CustomDrinkModel.swift
//  Hydro Comrade
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
    var alcoholAmount: Double
    var alcoholPercentage: Double
    var caffeineAmount: Double
    var isCustomWater: Bool
    
    func matchingID(matching: CustomDrinkModel, array: [CustomDrinkModel]) -> Int? {
        for index in 0..<array.count {
            if array[index].id == matching.id {
                return index
            }
        }
        return nil
    }
}



