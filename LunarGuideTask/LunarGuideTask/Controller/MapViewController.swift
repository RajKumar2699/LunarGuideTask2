//
//  ViewController.swift
//  LunarGuideTask
//
//  Created by Askme Technologies on 24/12/25.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var trailOverlay: MKPolyline?
    private var trailData: TrailData?
    private var infoCard: TrailInfoCardView?
    private var blueDot: BlueDotAnnotation?
    private var simulator: TrailSimulator?
    private var traveledCoordinates: [CLLocationCoordinate2D] = []
    private var hikeStartTime: Date?
    private var isNavigating = false
    private var endButton: UIButton?
    private var traveledPolyline: MKPolyline?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        enablePolylineTap()
        loadTrail()
    }
    
    private func setupUI() {
        mapView.delegate = self
        mapView.showsScale = true
        mapView.showsCompass = true
        
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = true
        
        mapView.showsUserLocation = false
        mapView.userTrackingMode = .none
    }
    
    
    private func loadTrail() {
        guard let url = Bundle.main.url(
            forResource: "cami-de-sant-jaume",
            withExtension: "kml"
        ),
              let data = KMLParser.parse(from: url) else {
            return
        }
        
        trailData = data
        
        let polyline = MKPolyline(
            coordinates: data.coordinates,
            count: data.coordinates.count
        )
        
        trailOverlay = polyline
        mapView.addOverlay(polyline)
        addTrailDots(data.coordinates)
        addDiscoveryAnnotations(data.coordinates)
        zoomToFit(polyline)
    }
    
    private func zoomToFit(_ polyline: MKPolyline) {
        mapView.setVisibleMapRect(
            polyline.boundingMapRect,
            edgePadding: UIEdgeInsets(top: 50, left: 40, bottom: 50, right: 40),
            animated: true
        )
    }
    
    private func addDiscoveryAnnotations(
        _ coordinates: [CLLocationCoordinate2D]
    ) {
        guard let start = coordinates.first,
              let end = coordinates.last else { return }
        
        let startAnnotation = TrailPointAnnotation(
            coordinate: start,
            type: .start,
            title: ""
        )
        
        let endAnnotation = TrailPointAnnotation(
            coordinate: end,
            type: .end,
            title: ""
        )
        
        mapView.addAnnotations([startAnnotation, endAnnotation])
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(
        _ mapView: MKMapView,
        viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {
        
        if annotation is BlueDotAnnotation {
            let id = "BlueDot"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? BlueDotView
            ?? BlueDotView(annotation: annotation, reuseIdentifier: id)
            return view
        }
        
        if let dot = annotation as? TrailDotAnnotation {
            let id = "TrailDot"
            
            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: id
            )
            ?? MKAnnotationView(annotation: dot, reuseIdentifier: id)
            
            view.annotation = dot
            view.image = makeWhiteDot()
            view.canShowCallout = false
            view.displayPriority = .defaultLow
            return view
        }
        
        if let trailPoint = annotation as? TrailPointAnnotation {
            let id = "TrailMarker"
            
            let marker = mapView.dequeueReusableAnnotationView(
                withIdentifier: id
            ) as? MKMarkerAnnotationView
            ?? MKMarkerAnnotationView(annotation: trailPoint, reuseIdentifier: id)
            
            marker.annotation = trailPoint
            marker.canShowCallout = true
            marker.displayPriority = .required
            
            if trailPoint.type == .start {
                marker.markerTintColor = .systemGreen
                marker.glyphImage = UIImage(named: "green_loc")
            } else {
                marker.markerTintColor = .systemRed
                marker.glyphImage = UIImage(named: "red_loc")
            }
            
            return marker
        }
        
        return nil
    }
    
    func mapView(
        _ mapView: MKMapView,
        rendererFor overlay: MKOverlay
    ) -> MKOverlayRenderer {
        
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 6
        renderer.lineJoin = .round
        renderer.lineCap = .round
        return renderer
    }
}

extension MapViewController {
    
    private func enablePolylineTap() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleMapTap(_:))
        )
        mapView.addGestureRecognizer(tap)
    }
    
    @objc private func handleMapTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        guard let polyline = trailOverlay else { return }
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        let mapPoint = MKMapPoint(coordinate)
        let tapPoint = renderer.point(for: mapPoint)
        
        let path = renderer.path.copy(
            strokingWithWidth: 24,
            lineCap: .round,
            lineJoin: .round,
            miterLimit: 0
        )
        
        if path.contains(tapPoint) {
            showTrailInfoCard(at: point, startCoordinate: coordinate)
        }
    }
}

extension MapViewController {
    
    private func showTrailInfoCard(at point: CGPoint, startCoordinate: CLLocationCoordinate2D) {
        infoCard?.removeFromSuperview()
        
        guard let data = trailData else { return }
        let distance = data.coordinates.distanceToClosestCoordinate(from: startCoordinate)
        
        let card = TrailInfoCardView(
            name: data.name,
            distanceKM: distance
        )
        
        card.onStartHiking = { [weak self] in
            self?.startBlueDotNavigation(from: startCoordinate)
        }
        
        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)
        infoCard = card
        
        let sidePadding: CGFloat = 16
        let cardWidth: CGFloat = 280
        
        var cardX = point.x - cardWidth / 2
        let maxX = view.bounds.width - cardWidth - sidePadding
        let minX = sidePadding
        cardX = max(minX, min(cardX, maxX))
        
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: cardX),
            card.topAnchor.constraint(equalTo: view.topAnchor, constant: max(point.y - 120, 16)),
            card.widthAnchor.constraint(equalToConstant: cardWidth)
        ])
        
        card.alpha = 0
        UIView.animate(withDuration: 0.25) {
            card.alpha = 1
        }
    }
    
    private func startBlueDotNavigation(from startCoordinate: CLLocationCoordinate2D) {
        guard !isNavigating else { return }
        isNavigating = true
        
        traveledCoordinates.removeAll()
        hikeStartTime = Date()
        
        let dot = BlueDotAnnotation(coordinate: startCoordinate)
        blueDot = dot
        mapView.addAnnotation(dot)
        
        guard let trailCoords = trailData?.coordinates else { return }
        let startIndex = trailCoords.enumerated().min(by: {
            let d1 = CLLocation(latitude: $0.element.latitude, longitude: $0.element.longitude)
                .distance(from: CLLocation(latitude: startCoordinate.latitude, longitude: startCoordinate.longitude))
            let d2 = CLLocation(latitude: $1.element.latitude, longitude: $1.element.longitude)
                .distance(from: CLLocation(latitude: startCoordinate.latitude, longitude: startCoordinate.longitude))
            return d1 < d2
        })?.offset ?? 0
        
        simulator = TrailSimulator(trail: Array(trailCoords[startIndex...]))
        simulator?.onUpdate = { [weak self] coord, heading in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard let blueDot = self.blueDot else { return }
                blueDot.coordinate = coord
                self.traveledCoordinates.append(coord)
                
                if let view = self.mapView.view(for: blueDot) as? BlueDotView {
                    view.rotate(to: heading)
                }
                
                let region = MKCoordinateRegion(center: coord,
                                                latitudinalMeters: 200,
                                                longitudinalMeters: 200)
                self.mapView.setRegion(region, animated: true)
            }
        }
        
        simulator?.onComplete = { [weak self] in
            DispatchQueue.main.async {
                self?.endHiking()
            }
        }
        
        simulator?.startSimulation()
        showEndButton()
    }
    
    private func endHiking() {
        simulator?.stopSimulation()
        simulator = nil
        if let blueDot = blueDot {
            mapView.removeAnnotation(blueDot)
            self.blueDot = nil
        }
        isNavigating = false
        endButton?.removeFromSuperview()
        endButton = nil
        
        let totalTime = Date().timeIntervalSince(hikeStartTime ?? Date())
        let distanceKM = traveledCoordinates.totalDistanceInKM()
        let avgSpeed = distanceKM / (totalTime / 3600)
        
        let message = """
            Time: \(Int(totalTime)) sec
            Distance: \(String(format: "%.2f", distanceKM)) km
            Avg Speed: \(String(format: "%.2f", avgSpeed)) km/h
            """
        
        let alert = UIAlertController(title: "Hike Summary",
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Done", style: .default))
        present(alert, animated: true)
    }
    
    private func showEndButton() {
        guard endButton == nil else { return }
        
        let button = UIButton(type: .system)
        button.setTitle("End Hiking", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(endHikingTapped), for: .touchUpInside)
        
        view.addSubview(button)
        endButton = button
        
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 160),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func endHikingTapped() {
        endHiking()
    }
    
    private func addTrailDots(
        _ coordinates: [CLLocationCoordinate2D]
    ) {
        guard coordinates.count > 2 else { return }
        
        let middlePoints = coordinates.dropFirst().dropLast()
        
        let dots = middlePoints.map {
            TrailDotAnnotation(coordinate: $0)
        }
        
        mapView.addAnnotations(dots)
    }
    
    
    private func makeWhiteDot() -> UIImage {
        let size = CGSize(width: 6, height: 6)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { _ in
            let circle = UIBezierPath(
                ovalIn: CGRect(origin: .zero, size: size)
            )
            UIColor.white.setFill()
            UIColor.systemBlue.setStroke()
            circle.lineWidth = 1
            circle.stroke()
            circle.fill()
        }
    }
}
