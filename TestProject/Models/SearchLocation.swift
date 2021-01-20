//
//  SearchLocation.swift
//  TestProject
//
//  Created by apple on 12/31/20.
//

import Foundation
import ObjectMapper


class SearchLocation: Mappable {
    
    var address: String?
    var placeId: String?
    var iconUrl: String?
    var description: String?
    
    
   
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        address <- map["address"]
        placeId <- map["placeId"]
        iconUrl <- map["iconUrl"]
        description <- map["description"]
    }
}
