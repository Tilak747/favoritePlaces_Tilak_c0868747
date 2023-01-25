//
//  PlaceManager.swift
//  favoritePlaces_Tilak_c0868747
//
//  Created by Tilak Acharya on 2023-01-24.
//

import Foundation
import CoreData
import MapKit

class PlaceManager{
    
    static let shared = PlaceManager()
    var projectName = "myFavPlaces"
    let fileManager = FileManager.default
    
    var places:[FavPlace]?
    
    func loadPlacesData(managedContext : NSManagedObjectContext){
        places = [FavPlace]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavPlaces")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            if results is [NSManagedObject] {
                for result in (results as! [NSManagedObject]) {
                    let title = result.value(forKey: "title") as! String
                    let lat = result.value(forKey: "lat") as! Double
                    let lng = result.value(forKey: "lng") as! Double
                    let postalCode = result.value(forKey: "postalCode") as! String
                    let locality = result.value(forKey: "locality") as! String
        
                    places?.append(FavPlace(title: title, lat: lat, lng: lng, postalCode: postalCode, locality: locality))
                }
            }
            
        } catch {
            print(error)
        }
    
    }
    
    
    func saveCoreData(managedContext : NSManagedObjectContext){
        clearData(managedContext: managedContext)
        for place in places! {
            let entity = NSEntityDescription.insertNewObject(forEntityName: "FavPlaces", into: managedContext)
            entity.setValue(place.title, forKey: "title")
            entity.setValue(place.lat, forKey: "lat")
            entity.setValue(place.lng, forKey: "lng")
            entity.setValue(place.postalCode, forKey: "postalCode")
            entity.setValue(place.locality, forKey: "locality")
        }
        
        do {
            try managedContext.save()
        } catch {
            print(error)
        }
    }
    
    
    func clearData(managedContext : NSManagedObjectContext){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavPlaces")
        do {
            let results = try managedContext.fetch(fetchRequest)
            for result in results {
                if let managedObject = result as? NSManagedObject {
                    managedContext.delete(managedObject)
                }
            }
        } catch {
            print("Error deleting records \(error)")
        }
    }
    
    func addPlace(place:FavPlace,managedContext : NSManagedObjectContext){
        places?.append(place)
        saveCoreData(managedContext: managedContext)
    }
    
}
