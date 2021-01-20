//
//  CoreDataManager.swift
//  TestProject
//
//  Created by apple on 1/1/21.
//

import Foundation
import CoreData
import UIKit


class CoreDataManager {
    
    private let searchedLocationEntity = "SearchedLocation"
    private let searchedPlaceEntity = "SearchedPlace"
    
    
    static let shared = CoreDataManager()
    private init () { }
    
    
    func saveSearchedLocation(searchedLocation: GApiResponse.NearBy, completion: @escaping (_ success: Bool) -> () ) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let entityDescription = NSEntityDescription.entity(forEntityName: searchedLocationEntity, in: managedContext) else {
            return
        }
        
        let searchedPlace = SearchedLocation(entity: entityDescription, insertInto: managedContext)
        searchedPlace.name = searchedLocation.formattedAddress
        searchedPlace.address = searchedLocation.description
        searchedPlace.latitude = searchedLocation.location.latitude ?? 0.0
        searchedPlace.longitude = searchedLocation.location.longitude ?? 0.0
        searchedPlace.placeId = searchedLocation.placeId
        searchedPlace.image = searchedLocation.image
        
        do {
            try managedContext.save()
            completion(true)
        } catch let error as NSError {
            completion(false)
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    public func fetchAllStudents() -> [SearchedLocation] {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        guard let appDelegate = delegate  else {
            return [SearchedLocation]()
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: searchedLocationEntity, in: managedContext)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        
        var resultArray: [SearchedLocation] = []
        
        do {
            resultArray = try managedContext.fetch(fetchRequest) as? [SearchedLocation] ?? [SearchedLocation]()
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return resultArray
    }
    
    func isAlreadyExists(placeId: String) -> Bool {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        guard let appDelegate = delegate  else {
            return false
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: searchedLocationEntity, in: managedContext)
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: searchedLocationEntity)
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "placeId = %@", placeId)
        
        var results: [NSManagedObject] = []
        
        do {
            results = try managedContext.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }

        return results.count > 0
    }

    func saveSearchedPlace(searchedPlace: SelectedLocation, completion: @escaping (_ success: Bool) -> () ) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let entityDescription = NSEntityDescription.entity(forEntityName: searchedPlaceEntity, in: managedContext) else {
            return
        }
        
        let searchedPlaceObj = SearchedPlace(entity: entityDescription, insertInto: managedContext)
        searchedPlaceObj.name = searchedPlace.name
        searchedPlaceObj.placeId = searchedPlace.placeId
        
        do {
            try managedContext.save()
            completion(true)
        } catch let error as NSError {
            completion(false)
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func isAlreadyPlacedSearched(placeId: String) -> Bool {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        guard let appDelegate = delegate  else {
            return false
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: searchedPlaceEntity, in: managedContext)
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: searchedPlaceEntity)
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "placeId = %@", placeId)
        
        var results: [NSManagedObject] = []
        
        do {
            results = try managedContext.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }

        return results.count > 0
    }
        
}
