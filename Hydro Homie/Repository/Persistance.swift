//
//  Persistance.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 6/16/21.
//

import CoreData

struct PersistanceController {
    static let shared = PersistanceController()

    let container: NSPersistentContainer
    init() {
        container = NSPersistentContainer(name: "HydrationModelCoreData")

        container.loadPersistentStores { (storeDesciption, error) in
            if let error = error as NSError?  {
                fatalError("Unresolved error: \(error)")
            }

        }
    }
}
