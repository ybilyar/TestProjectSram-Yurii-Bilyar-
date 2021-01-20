//
//  SearchedPlace+CoreDataProperties.swift
//  TestProject
//
//  Created by apple on 1/1/21.
//
//

import Foundation
import CoreData


extension SearchedPlace {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchedPlace> {
        return NSFetchRequest<SearchedPlace>(entityName: "SearchedPlace")
    }

    @NSManaged public var placeId: String?
    @NSManaged public var name: String?

}

extension SearchedPlace : Identifiable {

}
