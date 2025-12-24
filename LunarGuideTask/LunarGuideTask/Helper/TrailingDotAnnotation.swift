//
//  TrailingDotAnnotation.swift
//  LunarGuideTask
//
//  Created by Askme Technologies on 24/12/25.
//

import UIKit
import MapKit

final class TrailDotAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
