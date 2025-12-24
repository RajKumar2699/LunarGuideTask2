//
//  TrailingPointAnnotation.swift
//  LunarGuideTask
//
//  Created by Askme Technologies on 24/12/25.
//

import Foundation
import MapKit

enum TrailPointType {
    case start
    case end
}

final class TrailPointAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let type: TrailPointType
    let title: String?
    
    init(
        coordinate: CLLocationCoordinate2D,
        type: TrailPointType,
        title: String
    ) {
        self.coordinate = coordinate
        self.type = type
        self.title = title
    }
}
