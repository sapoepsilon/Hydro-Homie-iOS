//
//  HydrationDocument.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/6/21.
//

import SwiftUI

class HydrationDocument: ObservableObject {
    
    @Published var document: HydrationModel = HydrationModel()
    
    func updateHydration(cups: Int) {
        document.uploadCups(cups: cups)
    }
}

