//
//  SelectedLocation.swift
//  TestProject
//
//  Created by apple on 1/2/21.
//

import Foundation
import ObjectMapper


class SelectedLocation: Mappable {
    
    var long: Double?
    var lat: Double?
    var placeId: String?
    var name: String?
    
   
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        long <- map["long"]
        lat <- map["lat"]
        placeId <- map["placeId"]
        name <- map["name"]
    }
}
