//
//  PersistenceController.swift
//  Hydro Comrade
//
//  Created by Ismatulla Mansurov on 11/21/21.
//

import CoreData


struct PersistenceController {
    // A singleton for our entire app to use
    static let shared = PersistenceController()

    // Storage for Core Data
    let container: NSPersistentContainer

    // A test configuration for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        var id: Int64 = 0
        // Create 10 example programming languages.
        for _ in 0..<10 {
            let hydration = LocalHydration(context: controller.container.viewContext)
            hydration.id = id
            hydration.water = 0
            hydration.coffee = 0
            hydration.alcohol = 0
            hydration.date = "fillupData"
            hydration.isDiureticMode = false
            hydration.isAlcoholLocalTime = false
            id += 1
        }

        return controller
    }()

    // An initializer to load Core Data, optionally able
    // to use an in-memory store.
    init(inMemory: Bool = false) {
        // If you didn't name your model Main you'll need
        // to change this name below.
        container = NSPersistentContainer(name: "LocalHydration")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }

    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
            }
        }
    }
    
        func delete(object: NSManagedObject, completion: @escaping (Error?) -> () = {_ in}) {
            let context = container.viewContext
            context.delete(object)
            save()
        }
}

//
//struct PersistenceController {
//    static let shared = PersistenceController()
//
//    let container: NSPersistentContainer
//
//    init() {
//        container = NSPersistentContainer(name: "LocalHydration")
//
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error)")
//            }
//
//        })
//    }
//
//    func save(completion: @escaping (Error?) -> () = {_ in}) {
//        let context = container.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//                completion(nil)
//            } catch {
//                completion(error)
//            }
//        }
//    }
//
//    func delete(object: NSManagedObject, completion: @escaping (Error?) -> () = {_ in}) {
//        let context = container.viewContext
//        context.delete(object)
//        save(completion: completion)
//    }
//}
