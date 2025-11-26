//
//  Models.swift
//  MarathonApp-iOS
//
//  Created by Juan.A.Roldan on 29/07/2025.
//

import FirebaseFirestore
import CoreLocation

// Struct para las coordenadas
struct CoordinateData: Hashable, Identifiable {
    var id = UUID()
    var latitude: Double
    var longitude: Double
}

// Struct para el usuario
struct User: Identifiable {
    var id: String?
    var name: String
    var email: String
    var weeklyChallengeGoal: Double?

    init?(id: String, dictionary: [String: Any]) {
        guard
            let name = dictionary["name"] as? String,
            let email = dictionary["email"] as? String
        else {
            return nil
        }
        self.id = id
        self.name = name
        self.email = email
        if let goal = dictionary["weeklyChallengeGoal"] as? Double {
                    self.weeklyChallengeGoal = goal
                // Si falla, intenta leer un Int (ej: 0) y lo convierte a Double
                } else if let goal = dictionary["weeklyChallengeGoal"] as? Int {
                    self.weeklyChallengeGoal = Double(goal)
                // Si no es ninguno, es nil.
                } else {
                    self.weeklyChallengeGoal = nil
                }
                // --- FIN DEL CAMBIO ---
            }
        }


// Struct para la carrera
struct Run: Identifiable {
    var id: String?
    var distance: Double
    var duration: TimeInterval
    var date: Date
    var userId: String
    var path: [CoordinateData]?

    init(id: String?, distance: Double, duration: TimeInterval, date: Date, userId: String, path: [CoordinateData]?) {
        self.id = id
        self.distance = distance
        self.duration = duration
        self.date = date
        self.userId = userId
        self.path = path
    }

    init?(id: String, dictionary: [String: Any]) {
        guard
            let distance = dictionary["distance"] as? Double,
            let duration = dictionary["duration"] as? TimeInterval,
            let dateTimestamp = dictionary["date"] as? Timestamp,
            let userId = dictionary["userId"] as? String
        else {
            return nil
        }
        self.id = id
        self.distance = distance
        self.duration = duration
        self.date = dateTimestamp.dateValue()
        self.userId = userId
        if let pathData = dictionary["path"] as? [[String: Double]] {
            self.path = pathData.compactMap { dict in
                guard let lat = dict["latitude"], let lon = dict["longitude"] else { return nil }
                return CoordinateData(id: UUID(), latitude: lat, longitude: lon)
            }
        } else {
            self.path = nil
        }
    }
    
    var dictionary: [String: Any] {
        let pathData = path?.map { ["latitude": $0.latitude, "longitude": $0.longitude] }
        return [
            "distance": distance,
            "duration": duration,
            "date": Timestamp(date: date),
            "userId": userId,
            "path": pathData ?? []
        ]
    }
}

// Extensión para convertir coordenadas
extension CLLocationCoordinate2D {
    var coordinateData: CoordinateData {
        CoordinateData(latitude: self.latitude, longitude: self.longitude)
    }
}
