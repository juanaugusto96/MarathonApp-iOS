//
//  HistoryView.swift
//  MarathonApp-iOS
//
//  Created by Juan.A.Roldan on 29/07/2025.
//
//

import SwiftUI

// MARK: - Vista Principal del Historial

struct HistoryView: View {
    @EnvironmentObject private var runVM: RunViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        // --- CAMBIO: Envolvemos todo en un ZStack para el fondo ---
        ZStack {
            // --- CAMBIO: Añadimos el fondo gradiente ---
            LinearGradient(
                gradient: Gradient(colors: [.black, Color(white: 0.15), Color(white: 0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            NavigationStack {
                contentView
                    .navigationTitle("Historial de Carreras")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cerrar") {
                                dismiss()
                            }
                            // --- CAMBIO: Tinte del botón para que sea visible ---
                            .tint(.white)
                        }
                    }
                    .task {
                        await fetchRunsAsync()
                    }
            }
            // --- CAMBIO: Forzamos el esquema de color oscuro ---
            .preferredColorScheme(.dark)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if runVM.isLoading && runVM.runs.isEmpty {
            ProgressView("Cargando historial...")
                // --- CAMBIO: Color del texto de carga ---
                .foregroundColor(.white)
        } else if runVM.runs.isEmpty {
            Text("Aún no tienes carreras registradas.")
                .foregroundColor(.secondary)
                .padding()
        } else {
            List(runVM.runs) { run in
                RunHistoryRow(run: run)
                    // --- CAMBIO: Fondo de fila transparente ---
                    .listRowBackground(Color.clear)
            }
            // --- CAMBIO: Ocultar el fondo por defecto de la lista ---
            .scrollContentBackground(.hidden)
            .refreshable {
                await fetchRunsAsync()
            }
        }
    }
    
    private func fetchRunsAsync() async {
        if let userId = authVM.firebaseUser?.uid {
            runVM.fetchRuns(userId: userId)
        }
    }
}

// MARK: - Vista para la Fila del Historial

struct RunHistoryRow: View {
    let run: Run
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. EL MAPA (Parte superior de la tarjeta)
            if let path = run.path, !path.isEmpty {
                MapSnapshotView(coordinates: path)
                    .frame(height: 150) // Altura del mapa
                    .clipped()
            } else {
                // Si no hay ruta GPS, mostramos un mapa genérico o color
                ZStack {
                    Color.gray.opacity(0.2)
                    Image(systemName: "figure.run.circle")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
                .frame(height: 150)
            }
            
            // 2. LOS DATOS (Parte inferior de la tarjeta)
            HStack(alignment: .center, spacing: 16) {
                
                // Columna 1: Distancia (Destacada)
                VStack(alignment: .leading) {
                    Text("Distancia")
                        .font(.caption2)
                        .textCase(.uppercase)
                        .foregroundColor(.gray)
                    Text("\(run.distance / 1000, specifier: "%.2f") km")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                }
                
                Divider().background(Color.gray)
                
                // Columna 2: Tiempo
                VStack(alignment: .leading) {
                    Text("Tiempo")
                        .font(.caption2)
                        .textCase(.uppercase)
                        .foregroundColor(.gray)
                    Text(formatTime(run.duration))
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Columna 3: Fecha (Pequeña)
                Text(run.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(white: 0.1)) // Fondo gris muy oscuro para los datos
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
        .padding(.vertical, 6) // Separación entre tarjetas
    }
    
    
    // Métodos de formato
    private func formatTime(_ time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter.string(from: time) ?? "0s"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func calculatePace(distance: Double, duration: TimeInterval) -> String {
        guard distance > 0, duration > 0 else { return "--:--" }
        let paceInSecondsPerKm = duration / (distance / 1000)
        let minutes = Int(paceInSecondsPerKm) / 60
        let seconds = Int(paceInSecondsPerKm) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Vista de Ayuda para Estadísticas
struct StatLabel: View {
    let systemImage: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
            Text(text)
        }
    }
}

// MARK: - Vista Previa
#Preview {
    let authVM = AuthViewModel()
    let runVM = RunViewModel()
    
    runVM.runs = [
        Run(id: "1", distance: 5020, duration: 1820, date: .now, userId: "previewUser", path: nil),
        Run(id: "2", distance: 10150, duration: 4200, date: .now.addingTimeInterval(-86400), userId: "previewUser", path: nil)
    ]
    
    return HistoryView()
        .environmentObject(authVM)
        .environmentObject(runVM)
}
