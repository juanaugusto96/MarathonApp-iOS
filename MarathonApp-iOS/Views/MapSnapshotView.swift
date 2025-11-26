//
//  MapSnapshotView.swift
//  MarathonApp-iOS
//
//  Created by Juan.A.Roldan on 26/11/2025.
//



import SwiftUI
import MapKit

struct MapSnapshotView: View {
    let coordinates: [CoordinateData]
    @State private var snapshotImage: UIImage?
    @State private var isLoading = true

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. Fondo o Imagen generada
                if let image = snapshotImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    // Placeholder mientras carga (Gris oscuro con logo)
                    ZStack {
                        Color(white: 0.2)
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "map.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .onAppear {
                generateSnapshot(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }

    private func generateSnapshot(width: CGFloat, height: CGFloat) {
        guard !coordinates.isEmpty else {
            isLoading = false
            return
        }

        // 1. Configurar las opciones del snapshot
        let options = MKMapSnapshotter.Options()
        options.size = CGSize(width: width, height: height)
        options.mapType = .mutedStandard // Mapa limpio, estilo Strava
        options.traitCollection = UITraitCollection(userInterfaceStyle: .dark) // Modo oscuro

        // 2. Calcular la región para que quepa toda la ruta
        let locations = coordinates.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        let region = regionFor(coordinates: locations)
        options.region = region

        // 3. Generar la imagen
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                self.isLoading = false
                return
            }

            // 4. DIBUJAR LA LÍNEA (POLYLINE) SOBRE LA IMAGEN
            // Esto es necesario porque el snapshotter solo toma foto del mapa base, no de tus dibujos.
            let image = UIGraphicsImageRenderer(size: options.size).image { _ in
                // Dibuja la foto del mapa base
                snapshot.image.draw(at: .zero)

                // Configura el "lápiz" para la línea
                let path = UIBezierPath()
                let startPoint = snapshot.point(for: locations[0])
                path.move(to: startPoint)

                for coordinate in locations.dropFirst() {
                    let point = snapshot.point(for: coordinate)
                    path.addLine(to: point)
                }

                // Estilo de la línea
                UIColor.green.setStroke() // Color Verde Neon
                path.lineWidth = 4
                path.lineCapStyle = .round
                path.lineJoinStyle = .round
                path.stroke()
            }

            // 5. Actualizar la UI
            DispatchQueue.main.async {
                self.snapshotImage = image
                self.isLoading = false
            }
        }
    }

    // Función auxiliar para centrar el mapa en la ruta
    private func regionFor(coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        var minLat = 90.0, maxLat = -90.0
        var minLon = 180.0, maxLon = -180.0

        for coord in coordinates {
            if coord.latitude < minLat { minLat = coord.latitude }
            if coord.latitude > maxLat { maxLat = coord.latitude }
            if coord.longitude < minLon { minLon = coord.longitude }
            if coord.longitude > maxLon { maxLon = coord.longitude }
        }

        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.4, longitudeDelta: (maxLon - minLon) * 1.4) // 1.4 para dar margen
        return MKCoordinateRegion(center: center, span: span)
    }
}
