//
//  BlueDotView.swift
//  LunarGuideTask
//
//  Created by Askme Technologies on 24/12/25.
//

import MapKit

final class BlueDotView: MKAnnotationView {
    
    private var currentHeading: CLLocationDirection = 0
    
    override var annotation: MKAnnotation? {
        willSet {
            guard newValue != nil else {
                image = nil
                return
            }
            
            image = UIImage(systemName: "arrow.up.circle.fill")?
                .withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
            
            bounds = CGRect(x: 0, y: 0, width: 24, height: 24)
        }
    }
    
    func rotate(to heading: CLLocationDirection) {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.transform = CGAffineTransform(rotationAngle: CGFloat(heading * .pi / 180))
        }
    }
}
