# Lunar Guide – iOS Navigation App

Lunar Guide is an iOS application designed to simulate trail-based navigation with smooth marker movement, real-time heading updates, and MapKit integration. The app focuses on delivering a visually clean and flicker-free navigation experience.

---

## Features

- Trail simulation using coordinate interpolation
- Smooth marker (blue dot) movement without flicker
- Real-time heading/bearing calculation
- MapKit camera updates with pitch and heading
- Modular and testable simulation logic
- Universal iOS app icon support

---

## Core Components

### TrailSimulator
- Simulates movement along a predefined trail
- Handles segment transitions smoothly
- Emits continuous coordinate and heading updates
- Prevents snapping or blinking at segment boundaries

### Map Integration
- Uses `MKMapView`
- Custom annotation for navigation marker
- Camera follows simulated movement

---

## Tech Stack

- **Language:** Swift
- **Frameworks:**  
  - MapKit  
  - CoreLocation  
  - UIKit
- **Architecture:** Lightweight MVC
- **Platform:** iOS 12+

---
