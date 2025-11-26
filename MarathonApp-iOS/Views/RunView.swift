//
//  RunView.swift
//  MarathonApp-iOS
//
//  Created by Juan.A.Roldan on 29/07/2025.
//


import SwiftUI

struct RunView: View {
    @EnvironmentObject var runManager: RunManager
    @Binding var showRunView: Bool
    @State private var showResults = false

    private let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    var body: some View {
            ZStack {
                // Fondo Gradiente
                LinearGradient(
                    gradient: Gradient(colors: [
                        .black,
                        Color(white: 0.15),
                        Color(white: 0.3)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()
                    
                    // AQUÍ ANTES ESTABA EL BOTÓN DE DEBUG. YA NO ESTÁ.
                    
                    Text(timeFormatter.string(from: runManager.elapsedTime) ?? "00:00:00")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(runManager.isPaused ? .orange : .white)
                    
                    Text(String(format: "%.2f km", runManager.distance / 1000))
                        .font(.system(size: 40, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.1, green: 1.1, blue: 0.2))

                    Spacer()
                    
                    // Botones de control (Pausa/Stop)
                    HStack(spacing: 40) {
                        Button {
                            runManager.isPaused ? runManager.resumeRunning() : runManager.pauseRunning()
                        } label: {
                            Image(systemName: runManager.isPaused ? "play.fill" : "pause.fill")
                                .font(.largeTitle).padding().background(runManager.isPaused ? Color.green : Color.orange).clipShape(Circle())
                        }
                        
                        Button {
                            runManager.stopRunning()
                            showResults = true
                        } label: {
                            Image(systemName: "stop.fill")
                                .font(.largeTitle).padding().background(Color.red).clipShape(Circle())
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.bottom, 50)
                }
                .padding()
                .sheet(isPresented: $showResults, onDismiss: {
                    showRunView = false
                }) {
                    ResultView()
                        .preferredColorScheme(.dark)
                }
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
    RunView(showRunView: .constant(true))
        .environmentObject(runManager)
        // También es buena idea inyectar los otros por si ResultView los necesita.
        .environmentObject(authVM)
        .environmentObject(runVM)
}
