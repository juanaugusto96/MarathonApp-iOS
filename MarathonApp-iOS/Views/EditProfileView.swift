//
//  EditProfileView.swift
//  MarathonApp-iOS
//
//  Created by Juan.A.Roldan on 25/11/2025.


import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var email: String = "" // Solo lectura
    
    var body: some View {
        ZStack {
            // Fondo Gradiente Oscuro
            LinearGradient(
                gradient: Gradient(colors: [.black, Color(white: 0.15)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 25) {
                
                // Título
                Text("Editar Perfil")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Avatar (Placeholder por ahora)
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                        .foregroundColor(.white)
                }
                .overlay(Circle().stroke(Color.green, lineWidth: 2))
                .shadow(radius: 10)
                
                // Formulario
                VStack(alignment: .leading, spacing: 15) {
                    
                    // Campo Nombre
                    VStack(alignment: .leading) {
                        Text("Nombre de Usuario")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        TextField("Tu nombre", text: $name)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    
                    // Campo Email (Deshabilitado/Solo lectura)
                    VStack(alignment: .leading) {
                        Text("Correo Electrónico")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.black.opacity(0.3)) // Más oscuro para indicar disabled
                            .cornerRadius(10)
                            .foregroundColor(.gray)
                            .disabled(true)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Botón Guardar
                Button {
                    authVM.updateUserProfile(name: name) { success in
                        if success {
                            dismiss()
                        }
                    }
                } label: {
                    if authVM.isLoading {
                        ProgressView().tint(.black)
                    } else {
                        Text("Guardar Cambios")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(15)
                    }
                }
                .disabled(authVM.isLoading)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        // Cargar datos al aparecer la vista
        .onAppear {
            if let user = authVM.currentUser {
                self.name = user.name
                self.email = user.email
            }
        }
    }
}

#Preview {
    EditProfileView().environmentObject(AuthViewModel())
}
