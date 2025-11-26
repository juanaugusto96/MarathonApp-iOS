//
//  ResultView.swift
//  MarathonApp-iOS
//
//  Created by Juan.A.Roldan on 29/07/2025.
//
import SwiftUI
import MapKit

struct ResultView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var runManager: RunManager

    var body: some View {
        NavigationView {
            VStack {
                // Resumen de estadísticas
                HStack(spacing: 20) {
                    StatItem(label: "Distancia", value: String(format: "%.2f km", runManager.distance / 1000))
                    StatItem(label: "Duración", value: formatTime(runManager.elapsedTime))
                    StatItem(label: "Ritmo Prom.", value: calculatePace() + " /km")
                }
                .padding()

                // Mapa con la ruta
                Map {
                    if !runManager.pathCoordinates.isEmpty {
                        MapPolyline(coordinates: runManager.pathCoordinates)
                            .stroke(.orange, lineWidth: 5)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Resumen de Carrera")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Finalizar") {
                        dismiss()
                    }
                }
            }
        }
    }

    // Funciones de formato
    private func formatTime(_ time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: time) ?? "N/A"
    }
    
    private func calculatePace() -> String {
        let distanceInKm = runManager.distance / 1000
        guard distanceInKm > 0, runManager.elapsedTime > 0 else { return "--:--" }
        let paceInSecondsPerKm = runManager.elapsedTime / distanceInKm
        let minutes = Int(paceInSecondsPerKm) / 60
        let seconds = Int(paceInSecondsPerKm) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline).bold()
        }
    }
}
#Preview {
    // 1. Creamos las instancias mock necesarias.
    let authVM = AuthViewModel()
    let runVM = RunViewModel()
    let runManager = RunManager(authVM: authVM, runVM: runVM)

    // 2. Pasamos un binding constante para 'showRunView' y
    //    el environment object que la vista necesita.
    ResultView()
        .environmentObject(runManager)
        // También es buena idea inyectar los otros por si ResultView los necesita.
        .environmentObject(authVM)
        .environmentObject(runVM)
}
