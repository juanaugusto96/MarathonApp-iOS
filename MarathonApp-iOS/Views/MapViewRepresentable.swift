//
//  MapViewRepresentable.swift
//  MarathonApp-iOS
//
//  Created by Juan.A.Roldan on 29/07/2025.
//

import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var showsUserLocation: Bool
    var userTrackingMode: MKUserTrackingMode

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = region
        mapView.showsUserLocation = showsUserLocation
        mapView.setUserTrackingMode(userTrackingMode, animated: true)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
    }
}
