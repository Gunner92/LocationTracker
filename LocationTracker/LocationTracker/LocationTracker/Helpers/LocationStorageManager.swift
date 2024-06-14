//
//  LocationStorageManager.swift
//  LocationTracker
//
//  Created by Burak Güner on 14.06.2024.
//

import Foundation

class LocationStorageManager {
    
    public static let sharedInstance = LocationStorageManager()

    private let locationsKey = "LocationsStorageKey"

    func storeLocations(locations:[LocationModel]) {
        do {
            let jsonString = try String(data: JSONEncoder().encode(locations), encoding: .utf8)
            UserDefaults.standard.setValue(jsonString, forKey: locationsKey)
        } catch {
            print(error)
        }
    }

    func insertBackgroundLocation(location:LocationModel) {
        do {
            var locations = getLocations()
            locations?.append(location)
            let jsonString = try String(data: JSONEncoder().encode(locations), encoding: .utf8)
            UserDefaults.standard.setValue(jsonString, forKey: locationsKey)
        } catch {
            print(error)
        }
    }

    func getLocations() -> [LocationModel]? {
        do {
            guard let jsonString = UserDefaults.standard.string(forKey: locationsKey) else { return nil }
            guard let locationsData = jsonString.data(using: .utf8) else { return nil }
            return try JSONDecoder().decode([LocationModel].self, from: locationsData)
        } catch {
            print(error)
            return nil
        }
    }

    func resetLocations(location:LocationModel) {
        UserDefaults.standard.removeObject(forKey: locationsKey)
    }
}
