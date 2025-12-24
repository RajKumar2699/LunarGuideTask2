//
//  Utility.swift
//  LunarGuideTask
//
//  Created by Askme Technologies on 24/12/25.
//

import CoreLocation

extension Array where Element == CLLocationCoordinate2D {
    
    func totalDistanceInKM() -> Double {
        guard count > 1 else { return 0 }
        var distance: CLLocationDistance = 0
        
        for i in 1..<count {
            let start = CLLocation(latitude: self[i - 1].latitude,
                                   longitude: self[i - 1].longitude)
            let end = CLLocation(latitude: self[i].latitude,
                                 longitude: self[i].longitude)
            distance += start.distance(from: end)
        }
        return distance / 1000
    }
    
    func distanceToClosestCoordinate(from coordinate: CLLocationCoordinate2D) -> Double {
        guard !isEmpty else { return 0 }
        
        let tapLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        var closestIndex = 0
        var minDistance = CLLocationDistance.infinity
        for (i, coord) in self.enumerated() {
            let loc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            let d = loc.distance(from: tapLocation)
            if d < minDistance {
                minDistance = d
                closestIndex = i
            }
        }
        
        var distance: CLLocationDistance = 0
        guard closestIndex >= 1 else { return 0 }
        
        for i in 1...closestIndex {
            let start = CLLocation(latitude: self[i - 1].latitude, longitude: self[i - 1].longitude)
            let end = CLLocation(latitude: self[i].latitude, longitude: self[i].longitude)
            distance += start.distance(from: end)
        }
        return distance / 1000
    }
}
