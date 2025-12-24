//
//  KMLParser.swift
//  LunarGuideTask
//
//  Created by Askme Technologies on 24/12/25.
//

import Foundation
import CoreLocation

final class KMLParser {
    
    static func parse(from url: URL) -> TrailData? {
        guard let data = try? Data(contentsOf: url),
              let xml = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        let name = extractName(xml) ?? "Cami de Sant Jaume"
        let coordinates = extractCoordinates(xml)
        
        guard !coordinates.isEmpty else { return nil }
        
        return TrailData(name: name, coordinates: coordinates)
    }
    
    private static func extractName(_ xml: String) -> String? {
        let regex = try? NSRegularExpression(pattern: "<Placemark>.*?<name>(.*?)</name>")
        guard let match = regex?.firstMatch(
            in: xml,
            range: NSRange(xml.startIndex..., in: xml)
        ),
              let range = Range(match.range(at: 1), in: xml) else {
            return nil
        }
        return String(xml[range])
    }
    
    private static func extractCoordinates(_ xml: String) -> [CLLocationCoordinate2D] {
        var result: [CLLocationCoordinate2D] = []
        
        let regex = try? NSRegularExpression(
            pattern: "<coordinates>(.*?)</coordinates>",
            options: .dotMatchesLineSeparators
        )
        
        guard let match = regex?.firstMatch(
            in: xml,
            range: NSRange(xml.startIndex..., in: xml)
        ),
              let range = Range(match.range(at: 1), in: xml) else {
            return []
        }
        
        let coordText = xml[range]
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        for point in coordText.split(separator: " ") {
            let values = point.split(separator: ",")
            if values.count >= 2,
               let lon = Double(values[0]),
               let lat = Double(values[1]) {
                result.append(
                    CLLocationCoordinate2D(latitude: lat, longitude: lon)
                )
            }
        }
        return result
    }
}
