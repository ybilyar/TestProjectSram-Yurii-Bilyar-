//
//  UserDefaultsManager.swift
//  TestProject
//
//  Created by apple on 1/2/21.
//

import Foundation


class UserDefaultsManager {
    
    private let userDefaults = UserDefaults.standard
    static var shared = UserDefaultsManager()
    
    private init () { }
    
    private let userJson = "savedLocation.json"
    
    
    func saveLocation(_ location: SelectedLocation) {
        userDefaults.set(location.toJSON(), forKey: userJson)
        userDefaults.synchronize()
    }
    
    func readUser() -> SelectedLocation {
        if let json = userDefaults.dictionary(forKey: userJson) , let user = SelectedLocation(JSON: json) {
            return user
        }
        return SelectedLocation()
    }
    
}
