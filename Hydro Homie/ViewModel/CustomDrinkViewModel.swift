//
//  CustomDrinkViewModel.swift
//  Hydro Homie
//
//  Created by Ismatulla Mansurov on 7/10/21.
//

import SwiftUI
import Firebase

class CustomDrinkViewModel: ObservableObject {
    
    
    //Quick drink menu  variables
    @Published var drinkOpacity: Double = 0
    @Published var coffeeOpacity: Double = 0
    @Published var waterOpacity: Double = 0
    @Published var alcoholOpacity: Double = 0
    
    let db = Firestore.firestore()
    let today = Date()
    @ObservedObject var hydrationDocument = HydrationDocument()
    @Published var customDrinks: [CustomDrinkModel] = []
    @Published var customDrinkObject: CustomDrinkModel = CustomDrinkModel(id: 0, name: "name", isAlcohol: false, isCaffeine: false, amount: 23, alcoholAmount: 0, alcoholPercentage: 0, caffeineAmount: 0, isCustomWater: false)
    
    var drinksArray: [CustomDrinkModel] = []
    var customDrinkDictionary: [[String:Any]] = [[
        "id": 0,
        "name": "",
        "isAlcohol": false,
        "isCaffeine": false,
        "isCustomWater": false,
        "amount": 0,
        "alcoholAmount": 0,
        "alcoholPercentage": 0,
        "caffeineAmount": 0
    ]]
    init() {
        self.getAllDrinks()
    }
    
    func deleteCustomDrink(customDrink: CustomDrinkModel) {
//        db.collection("users").document("customDrinks").updateData([AnyHashable : Any])
  
        let deletingDrinkID: Int = customDrink.matchingID(matching: customDrink, array: customDrinks)! // fix from the force unwrap to proper Int
        //1. delete it from the published array
        self.customDrinks.remove(at: deletingDrinkID)
        self.drinksArray.remove(at: deletingDrinkID)
        getDrinkOpacity()

        //2. Create a dictionary with the fields of the published array.
        var drinkDictionaryArray: [[String:Any]] = []
        
        for drink in self.customDrinks {
            
            let customDrinkDictionary: [String:Any] = [
                "id": drink.id,
                "name": drink.name,
                "isAlcohol": drink.isAlcohol,
                "isCaffeine": drink.isCaffeine,
                "isCustomWater": drink.isCustomWater,
                "amount": drink.amount,
                "alcoholAmount": drink.alcoholAmount,
                "alcoholPercentage": drink.alcoholPercentage,
                "caffeineAmount": drink.caffeineAmount
            ]
            drinkDictionaryArray.append(customDrinkDictionary)
        }
        // 3. Delete the document from the Firestore
        db.collection("users").document("customDrinks\(self.hydrationDocument.userID())").delete()

        // 4. Create a new document on the Firestore, but without the deleted Custom Drink
        db.collection("users").document("customDrinks\(self.hydrationDocument.userID())").setData([
            "customDrinks": drinkDictionaryArray,
        ]) { err in
            if let err = err {
                print("Error updating document: \(err )")
            } else {
                print("Document successfully updated")

            }
        }
        // 5. Delete the field from the UserDefaults
                do {
                    // Create JSON Decoder
                    let encoder = JSONEncoder()
                    // Decode Note
                    let enodedArray = try encoder.encode(self.customDrinks) //encoding the arrau
                    UserDefaults.standard.set(0, forKey: "fetchCustomDrink") // seting to false, so the user won't connect to the Firebase
                    UserDefaults.standard.set(enodedArray, forKey: "customDrinksArray") //setting the customDrink array
                } catch {
                    print("Unable to Decode Note (\(error))")
                    UserDefaults.standard.set(1, forKey: "fetchCustomDrink") // seting to true, so the user will fetch the data from the firebase
                }
    }
    
    func addCustomDrink(newCustomDrink: CustomDrinkModel) -> String {
        
        let customDrinkDictionary: [String:Any] = [
            "id": newCustomDrink.id,
            "name": newCustomDrink.name,
            "isAlcohol": newCustomDrink.isAlcohol,
            "isCaffeine": newCustomDrink.isCaffeine,
            "isCustomWater": newCustomDrink.isCustomWater,
            "amount": newCustomDrink.amount,
            "alcoholAmount": newCustomDrink.alcoholAmount,
            "alcoholPercentage": newCustomDrink.alcoholPercentage,
            "caffeineAmount": newCustomDrink.caffeineAmount
        ]
        var Error: String = "Written successfully"
        print("customDrink Dictionary values\(customDrinkDictionary.debugDescription)")
        
        db.collection("users").document("customDrinks\(self.hydrationDocument.userID())").setData([
                "customDrinks": FieldValue.arrayUnion([
                    customDrinkDictionary
                ])
             ], merge: true)
            { err in
               if let err = err {
                   print("Error writing document: \(err)")
                Error = err.localizedDescription
               }  else {
                   // store the customDrink into the UserDefaults
                   var drinksArray: [CustomDrinkModel] = []
                   do {
                       // Create JSON Encoder
                       let encoder = JSONEncoder()
                       if let data = UserDefaults.standard.data(forKey: "customDrinksArray") {
                           do {
                               // Create JSON Decoder
                               let decoder = JSONDecoder()
                               // Decode Note
                               drinksArray = try decoder.decode([CustomDrinkModel].self, from: data) //getting previouse encoded array into a variable
                               // if the array had any variables stored beforehand, than adding more and storing in userdefaults
                               if drinksArray != [] {
                                   drinksArray.append(newCustomDrink)
                                self.customDrinks.append(newCustomDrink)

                                   let enodedArray = try encoder.encode(drinksArray) //encoding the arrau
                                   UserDefaults.standard.set(1, forKey: "fetchCustomDrink") // seting to false, so the user won't connect to the Firebase
                                   UserDefaults.standard.set(enodedArray, forKey: "customDrinksArray") //setting the customDrink array
                               } else { //else add the new drinks
                                   drinksArray.append(newCustomDrink)
                                   let enodedArray = try encoder.encode(drinksArray) //encoding the arrau
                                   UserDefaults.standard.set(1, forKey: "fetchCustomDrink") // seting to false, so the user won't connect to the Firebase
                                   UserDefaults.standard.set(enodedArray, forKey: "customDrinksArray") //setting the customDrink array
                               }
                           } catch {
                               print("Unable to Decode Note (\(error))")
                               UserDefaults.standard.set(1, forKey: "fetchCustomDrink") // seting to true, so the user will fetch the data from the firebase
                           }
                       }
                       //get the array with the current drinks
                       // Encode Note
                   }
              
                print("Document successfully written!")

               }
            }
//        print("custom Drinks array: \(self.customDrinks)")
//        print("local Drinks array: \(self.drinksArray)")
        self.getDrinkOpacity()
        self.getAllDrinks()
        return Error
    }
    
    //MARK: Fetch from the Firebase
    
    func fetchFromServer() {
        db.collection("users").document("customDrinks\(self.hydrationDocument.userID())").addSnapshotListener { (querySnapshot, error) in
            if (error != nil) {
                print(error!.localizedDescription)
                return
            }   else if(querySnapshot!.data() != nil) {
                self.drinksArray.removeAll()
                let document = querySnapshot!.data()
                self.customDrinkDictionary = ((document!["customDrinks"] as? [[String:Any]])!)
            
                print("document \(document.debugDescription)")
                print("dictionary of custom drinks\(self.customDrinkDictionary.debugDescription)")
                
                for customDrink in self.customDrinkDictionary {
                    self.customDrinkObject.id = customDrink["id"] as? Int ?? 0
                    self.customDrinkObject.name = customDrink["name"] as? String ?? "none"
                    self.customDrinkObject.amount = customDrink["amount"] as? Double ?? 0
                    self.customDrinkObject.isCaffeine = customDrink["isCaffeine"] as? Bool ?? false
                    self.customDrinkObject.isAlcohol = customDrink["isAlcohol"] as? Bool ?? false
                    self.customDrinkObject.isCustomWater = customDrink["isCustomWater"] as? Bool ?? false
                    self.customDrinkObject.alcoholAmount = customDrink["alcoholAmount"] as? Double ?? 0
                    self.customDrinkObject.caffeineAmount = customDrink["caffeineAmount"] as? Double ?? 0
                    self.customDrinkObject.alcoholPercentage = customDrink["alcoholPercentage"] as? Double ?? 0
                    self.drinksArray.append(self.customDrinkObject)
                }
                
                if self.drinksArray != self.customDrinks {
                    self.customDrinks.removeAll()
                    self.customDrinks = self.drinksArray
                    UserDefaults.standard.set(0, forKey: "fetchCustomDrink")
                    
                    do {
                        // Create JSON Encoder
                        let encoder = JSONEncoder()
                        //get the array with the current drinks
                        // Encode Note
                        let data = try encoder.encode(self.drinksArray)
                        UserDefaults.standard.set(data, forKey: "customDrinksArray")

                    } catch {
                        print("Unable to Encode Note (\(error))")
                    }
                }
                print("custom Drinks array\(self.customDrinks.debugDescription)")
            } else {
            print("Document does not exist")
          }
        }
    }

    //MARK: Fetch Custom Drinks
    func getAllDrinks() {

        let fetch: Int = UserDefaults.standard.object(forKey: "fetchCustomDrink") as? Int ?? 1
        print ("fetch \(fetch)")
        if fetch == 0 { // if the user hasn't changed the current device, and/or the userdefaults still keeps the customDrinks
            // Read/Get Data
            if let data = UserDefaults.standard.data(forKey: "customDrinksArray") {
                do {
                    // Create JSON Decoder
                    let decoder = JSONDecoder()

                    // Decode Note
                    self.drinksArray = try decoder.decode([CustomDrinkModel].self, from: data)
                    self.customDrinks = self.drinksArray
                } catch {
                    print("Unable to Decode Note (\(error))")
                    fetchFromServer()
                }
            }
        } else if fetch == 1 || self.customDrinks.count < 1 {
            fetchFromServer()
        }
    }
    
func getDrinkOpacity() {
        
        var waterOpacity: Double = 0
        var coffeeOpacity: Double = 0
        var alcoholOpacity: Double = 0
        var drinkOpacity: Double = 0
        
//        print("getting data from getDrinkOpacity function \(drinksArray.debugDescription)")
        for drink in self.drinksArray {
            if drink.isCustomWater {
                waterOpacity = 1
                drinkOpacity = 1
            } else if drink.isAlcohol {
                alcoholOpacity = 1
                drinkOpacity = 1
            } else if drink.isCaffeine {
                coffeeOpacity = 1
                drinkOpacity = 1
            }
        }
       
        self.waterOpacity = waterOpacity
        self.drinkOpacity = drinkOpacity
        self.alcoholOpacity = alcoholOpacity
        self.coffeeOpacity = coffeeOpacity
    }
    
}

