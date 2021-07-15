//
//  CustomDrinkViewModel.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 7/10/21.
//

import SwiftUI
import Firebase

class CustomDrinkViewModel: ObservableObject {
    
    let db = Firestore.firestore()
    let today = Date()
    @ObservedObject var hydrationDocument = HydrationDocument()
    @Published var customDrinks: [CustomDrinkModel] = []
    
    init() {
        getAllDrinks()
    }
    
    func deleteCustomDrink(customDrink: CustomDrinkModel) -> String {
//        db.collection("users").document("customDrinks").updateData([AnyHashable : Any])
        print("data will be deleted ")
        let deletedData: String = "Deleted Data \(customDrink.name)"
        return deletedData
    }
    func addCustomDrink(newCustomDrink: CustomDrinkModel) -> String {
        
        let customDrinkDictionary: [String:Any] = [
            "id": newCustomDrink.id,
            "name": newCustomDrink.name,
            "isAlcohol": newCustomDrink.isAlcohol,
            "isCaffeine": newCustomDrink.isCaffeine,
            "amount": newCustomDrink.amount
        ]
        
        var Error: String = "Written successfully"
        
            db.collection("users").document("customDrinks").setData([
                "customDrinks": FieldValue.arrayUnion([
                    customDrinkDictionary
                ])
             ], merge: true)
            { err in
               if let err = err {
                   print("Error writing document: \(err)")
                Error = err.localizedDescription
               }  else {
                   print("Document successfully written!")
               }
            }
        return Error
    }
    
    func removeCustomDrink() {
        
    }
    
    
    //MARK: Fetch Custom Drinks
    func getAllDrinks() {
        var id: Int = 0
        var customDrinkDictionary: [[String:Any]] = [[
            "id": 0,
            "name": "",
            "isAlcohol": false,
            "isCaffeine": false,
            "amount": 0
        ]]

        db.collection("users").document("customDrinks").addSnapshotListener { (querySnapshot, error) in
            if (error != nil) {
                print(error!.localizedDescription)
                return
            }   else if(querySnapshot!.data() != nil) {
                let document = querySnapshot!.data()
                customDrinkDictionary = ((document!["customDrinks"] as? [[String:Any]])!)
            
//                print("document \(document?.debugDescription)")
//                print("dictionary of custom drinks\(customDrinkDictionary.debugDescription)")
                for customDrink in customDrinkDictionary {
                   
                    var oneCustomDrink: CustomDrinkModel = CustomDrinkModel(id: id, name: "N/A", isAlcohol: false, isCaffeine: false, amount: 0)
                    id += 1
                    
                    oneCustomDrink.id = customDrink["id"] as? Int ?? 0
                    oneCustomDrink.name = customDrink["name"] as? String ?? "none"
                    oneCustomDrink.amount = customDrink["amount"] as? Double ?? 0
                    oneCustomDrink.isCaffeine = customDrink["isCaffeine"] as? Bool ?? false
                    oneCustomDrink.isAlcohol = customDrink["isAlcohol"] as? Bool ?? false
                        
//                    self.customDrinks.append(oneCustomDrink)
                }
                print("custom Drinks array\(self.customDrinks.debugDescription)")
            } else {
            print("Document does not exist")
          }
        }
    }
    
}

