//
//  LocationModel.swift
//  LocationTracker
//
//  Created by Burak Güner on 13.06.2024.
//

import Foundation

struct LocationModel: Codable {
    let latitude: Double
    let longitude: Double
    let address: String?

    init(latitude: Double, longitude: Double, address: String?) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
}
