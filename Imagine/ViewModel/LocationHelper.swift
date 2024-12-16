//
//  LocationHelper.swift
//  Imagine
//
//  Created by Ryan Aparicio on 12/8/24.
//

import Foundation
import CoreLocation

class LocationHelper {
    static func getCoordinates(from place: String) async -> CLLocationCoordinate2D? {
        return await withCheckedContinuation { continuation in
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(place) { placemarks, error in
                if let coordinate = placemarks?.first?.location?.coordinate {
                    continuation.resume(returning: coordinate)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
