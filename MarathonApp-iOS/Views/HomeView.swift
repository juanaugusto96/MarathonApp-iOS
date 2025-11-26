//
//  HomeView.swift
//  MarathonApp-iOS
//
//  Created by Juan.A.Roldan on 29/07/2025.
//


import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var runManager: RunManager
    @EnvironmentObject var runVM: RunViewModel

    // Estados para navegación
    @State private var showingCountdown = false
    @State private var showingHistory = false
    @State private var showingChallengeSelection = false
    @State private var showRunView = false
    
    // Estado para el Menú Desplegable de Perfil
    @State private var showProfileMenu = false
    
    // Estado para abrir la vista de Edición de Perfil
    @State private var showingEditProfile = false
    
    // Estado para controlar que la notificación no salga múltiples veces en la misma sesión
    @State private var hasNotifiedChallenge = false

    var body: some View {
        ZStack {
            // 1. MAPA DE FONDO
            MapViewRepresentable(
                region: $runManager.region,
                showsUserLocation: true,
                userTrackingMode: .follow
            )
            .ignoresSafeArea()
            
            // Cierra el menú si tocas el mapa
            .onTapGesture {
                if showProfileMenu { showProfileMenu = false }
            }

            // 2. INTERFAZ SUPERIOR
            VStack {
                HStack(alignment: .top) {
                    
                    Spacer() // Empuja todo a la derecha
                    
                    // --- Botón Derecha: Perfil (Menú Desplegable) ---
                    VStack(alignment: .trailing) {
                        Button {
                            // Acción: Abrir/Cerrar menú con animación
                            withAnimation(.spring()) {
                                showProfileMenu.toggle()
                            }
                        } label: {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45)
                                .foregroundColor(Color.white)
                                .background(Color.black)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                                .overlay(Circle().stroke(Color.green, lineWidth: 2))
                        }
                        
                        // --- EL MENÚ DESPLEGABLE ---
                        if showProfileMenu {
                            ProfileDropdownMenu()
                                .transition(.scale(scale: 0.8, anchor: .topTrailing).combined(with: .opacity))
                        }
                    }
                }
                .padding() // Padding general de la cabecera
                
                // (El botón "pastilla" de Desafíos que estaba aquí, YA NO ESTÁ)
                
                // --- BARRA DE PROGRESO DEL DESAFÍO ---
                let userGoal = authVM.currentUser?.weeklyChallengeGoal ?? 0
                
                if userGoal > 0 {
                    // Si ya hay meta, solo mostramos la barra de progreso
                    ChallengeProgressView(
                        progress: runVM.weeklyProgressInMeters,
                        goal: userGoal
                    )
                    .padding(.horizontal)
                    .padding(.top, 10)
                } else {
                    // Si NO hay meta, mostramos este botón grande para invitar a elegir una
                    // (Esto es buen UX para que no quede el espacio vacío)
                    Button {
                        showingChallengeSelection = true
                    } label: {
                        HStack {
                            Image(systemName: "flag.checkered")
                            Text("Seleccionar Desafío Semanal")
                        }
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                        .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                
                Spacer()

                // --- BOTÓN INICIAR CARRERA (ABAJO) ---
                Button {
                    if runManager.authorizationStatus == .authorizedWhenInUse || runManager.authorizationStatus == .authorizedAlways {
                        showingCountdown = true
                    } else {
                        runManager.checkAndRequestLocationPermission()
                    }
                } label: {
                    Text("INICIAR")
                        .font(.title2.bold())
                        .tracking(2)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [Color.green, Color(red: 0.2, green: 0.8, blue: 0.4)], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(30)
                        .shadow(color: .green.opacity(0.5), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        // --- MODALES Y NAVEGACIÓN ---
        .sheet(isPresented: $showingCountdown) { CountDownView() }
        .sheet(isPresented: $showingHistory) { HistoryView() }
        .sheet(isPresented: $showingChallengeSelection) { ChallengeSelectionView() }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
                .preferredColorScheme(.dark)
        }
        .fullScreenCover(isPresented: $showRunView) { RunView(showRunView: $showRunView) }
        
        // --- CARGA INICIAL ---
        .task {
            runManager.checkAndRequestLocationPermission()
            if let userId = authVM.firebaseUser?.uid {
                runVM.fetchRuns(userId: userId)
            }
        }
        .onChange(of: runManager.isRunning) { _, isNowRunning in
            if isNowRunning { showRunView = true }
        }
        
        // --- LÓGICA DE NOTIFICACIÓN ---
        .onChange(of: runVM.weeklyProgressInMeters) { _, newProgress in
            checkForChallengeCompletion(progress: newProgress)
        }
    }
    
    // Función auxiliar para chequear el desafío
    private func checkForChallengeCompletion(progress: Double) {
        guard let goal = authVM.currentUser?.weeklyChallengeGoal, goal > 0 else { return }
        
        if progress >= goal && !hasNotifiedChallenge {
            NotificationManager.instance.scheduleNotification(
                title: "¡Desafío Completado! 🏆",
                subtitle: "Has alcanzado tu meta de \(Int(goal/1000))km esta semana."
            )
            hasNotifiedChallenge = true
        }
    }
    
    // --- VISTA DEL MENÚ DESPLEGABLE (CON LA NUEVA OPCIÓN) ---
    @ViewBuilder
    func ProfileDropdownMenu() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Opción 1: Historial
            Button {
                showProfileMenu = false
                showingHistory = true
            } label: {
                HStack {
                    Image(systemName: "clock")
                    Text("Historial")
                }
                .foregroundColor(.primary)
            }
            
            Divider()

            // Opción 2: Desafíos (NUEVO AQUÍ)
            Button {
                showProfileMenu = false
                showingChallengeSelection = true
            } label: {
                HStack {
                    Image(systemName: "flag.checkered")
                    Text("Desafíos")
                }
                .foregroundColor(.primary)
            }
            
            Divider()
            
            // Opción 3: Editar Perfil
            Button {
                showProfileMenu = false
                showingEditProfile = true
            } label: {
                HStack {
                    Image(systemName: "pencil")
                    Text("Editar Perfil")
                }
                .foregroundColor(.primary)
            }
            
            Divider()
            
            // Opción 4: Cerrar Sesión
            Button {
                showProfileMenu = false
                authVM.signOut()
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Cerrar Sesión")
                }
                .foregroundColor(.red)
            }
        }
        .padding()
        .frame(width: 180)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
        .padding(.top, 5)
    }
}
