//
//  LoginView.swift
//  MarathonApp-iOS
//
//  Created by Juan.A.Roldan on 29/07/2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false

    var body: some View {
        // --- CAMBIO 1: Envolver todo en un ZStack ---
        
        
        ZStack {
          
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .black,
                            Color(white: 0.3), // Un gris muy oscuro
                            Color(white: 0.5)   // Un gris un poco más claro
                        ]),
                        startPoint: .bottomTrailing, // El gradiente empieza arriba
                        endPoint: .zero // Y termina abajo
                    )
                    .ignoresSafeArea()

        
            VStack(alignment: .leading, spacing: 20) {
                Text("Iniciar Sesión")
                
                    .font(Font.custom("Chalkduster", size: 34))
                    .padding(.bottom, 30)
                    // --- CAMBIO 3: Ajustar color del texto ---
                    .foregroundColor(.green)
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                SecureField("Contraseña", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                if !authVM.errorMessage.isEmpty {
                    Text(authVM.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                
                Spacer()
                
                Button {
                    authVM.login(email: email, password: password)
                } label: {
                    HStack {
                        Spacer()
                        if authVM.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Iniciar Sesión").bold()
                        }
                        Spacer()
                    }.padding().background(Color.gray).foregroundColor(.black).cornerRadius(10)
                }.disabled(authVM.isLoading)
                
                HStack {
                    Spacer()
                    Text("¿No tienes cuenta?")
                        .font(.footnote)
                        // --- CAMBIO 3: Ajustar color del texto ---
                        .foregroundColor(.gray)
                    
                    Button("Regístrate") { showingSignUp = true }
                        .tint(.blue)
                        .font(.footnote)
                    Spacer()
                }
            }
            .padding()
            .sheet(isPresented: $showingSignUp) {
                // Para que la vista de registro también tenga fondo negro:
                SignUpView()
                    .preferredColorScheme(.dark)
            }
        }
    }
}
#Preview {
    // 1. Creamos una instancia de AuthViewModel solo para la vista previa.
    let authVM = AuthViewModel()

    // 2. Inyectamos el objeto en el entorno de LoginView
    //    para que la vista y sus sub-vistas (como SignUpView) puedan usarlo.
    LoginView()
        .environmentObject(authVM)
}
