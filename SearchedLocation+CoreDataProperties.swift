//
//  SearchedLocation+CoreDataProperties.swift
//  TestProject
//
//  Created by apple on 1/1/21.
//
//

import Foundation
import CoreData


extension SearchedLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchedLocation> {
        return NSFetchRequest<SearchedLocation>(entityName: "SearchedLocation")
    }

    @NSManaged public var name: String?
    @NSManaged public var address: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var image: NSObject?
    @NSManaged public var placeId: String?

}

extension SearchedLocation : Identifiable {

}
