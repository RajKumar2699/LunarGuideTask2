//
//  BlueDotAnnotation.swift
//  LunarGuideTask
//
//  Created by Askme Technologies on 24/12/25.
//

import MapKit

final class BlueDotAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var heading: CLLocationDirection = 0
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}
