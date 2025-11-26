//
//   ChallengeProgressView.swift
//  MarathonApp-iOS
//
//  Created by Juan.A.Roldan on 29/07/2025.
//

import SwiftUI
struct ChallengeProgressView: View {
    let progress: Double
    let goal: Double

    private var percentage: Double {
        guard goal > 0 else { return 0.0 }
        return min(progress / goal, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Desafío Semanal")
                    .font(.headline)
                    .foregroundColor(.white) // Asegurar texto blanco
                
                Spacer()
                
                Text("\(progress / 1000, specifier: "%.1f") / \(Int(goal / 1000)) km")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // Barra de progreso personalizada
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 1. Fondo de la barra (Gris oscuro)
                    Capsule()
                        .frame(width: geometry.size.width, height: 12)
                        .foregroundColor(Color.white.opacity(0.2))
                    
                    // 2. Relleno de la barra (Verde)
                    Capsule()
                        .frame(width: geometry.size.width * percentage, height: 12)
                        .foregroundColor(.green)
                        .animation(.spring(), value: percentage) // Animación suave
                }
            }
            .frame(height: 12) // Altura fija para el GeometryReader
            
        }
        .padding()
        .background(.ultraThinMaterial) // Fondo translúcido tipo iOS
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

