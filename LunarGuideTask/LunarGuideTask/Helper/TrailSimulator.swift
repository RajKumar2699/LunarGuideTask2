//
//  TrailSimulator.swift
//  LunarGuideTask
//
//  Created by Askme Technologies on 24/12/25.
//

import CoreLocation

final class TrailSimulator {
    
    private let coordinates: [CLLocationCoordinate2D]
    private var segmentIndex = 0
    private var distanceAlongSegment: CLLocationDistance = 0
    private var timer: Timer?
    
    var onUpdate: ((CLLocationCoordinate2D, CLLocationDirection) -> Void)?
    var onComplete: (() -> Void)?
    
    private let speed: CLLocationDistance = 20
    
    init(trail: [CLLocationCoordinate2D]) {
        self.coordinates = trail
    }
    
    func startSimulation(interval: TimeInterval = 0.05) {
        guard coordinates.count > 1 else {
            onComplete?()
            return
        }
        timer?.invalidate()
        segmentIndex = 0
        distanceAlongSegment = 0
        timer = Timer.scheduledTimer(withTimeInterval: interval,
                                     repeats: true) { [weak self] _ in
            self?.advance(deltaTime: interval)
        }
    }
    
    func stopSimulation() {
        timer?.invalidate()
        timer = nil
    }
    
    private func advance(deltaTime: TimeInterval) {
        guard segmentIndex < coordinates.count - 1 else {
            stopSimulation()
            onComplete?()
            return
        }
        
        var start = coordinates[segmentIndex]
        var end = coordinates[segmentIndex + 1]
        
        var startLoc = CLLocation(latitude: start.latitude, longitude: start.longitude)
        var endLoc = CLLocation(latitude: end.latitude, longitude: end.longitude)
        var segmentDistance = startLoc.distance(from: endLoc)
        
        if segmentDistance == 0 {
            segmentIndex += 1
            distanceAlongSegment = 0
            return
        }
        
        distanceAlongSegment += speed * deltaTime
        
        while distanceAlongSegment >= segmentDistance && segmentIndex < coordinates.count - 1 {
            distanceAlongSegment -= segmentDistance
            segmentIndex += 1
            
            if segmentIndex < coordinates.count - 1 {
                start = coordinates[segmentIndex]
                end = coordinates[segmentIndex + 1]
                startLoc = CLLocation(latitude: start.latitude, longitude: start.longitude)
                endLoc = CLLocation(latitude: end.latitude, longitude: end.longitude)
                segmentDistance = startLoc.distance(from: endLoc)
            } else {
                stopSimulation()
                onComplete?()
                return
            }
        }
        
        let t = max(0, min(distanceAlongSegment / max(segmentDistance, 0.0001), 1))
        let coord = TrailSimulator.interpolate(from: start, to: end, t: t)
        let heading = TrailSimulator.calculateBearing(from: start, to: end)
        onUpdate?(coord, heading)
    }
    
    
    static func interpolate(from: CLLocationCoordinate2D,
                            to: CLLocationCoordinate2D,
                            t: Double) -> CLLocationCoordinate2D {
        let easedT = 0.5 - 0.5 * cos(t * .pi)
        
        let lat = from.latitude + (to.latitude - from.latitude) * t
        let lon = from.longitude + (to.longitude - from.longitude) * t
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    static func calculateBearing(from: CLLocationCoordinate2D,
                                 to: CLLocationCoordinate2D) -> CLLocationDirection {
        let lat1 = from.latitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let lonDiff = (to.longitude - from.longitude) * .pi / 180
        
        let y = sin(lonDiff) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lonDiff)
        
        let bearing = atan2(y, x) * 180 / .pi
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }
}
