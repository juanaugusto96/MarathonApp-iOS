//
//  AuthViewModel.swift
//  MarathonApp-iOS
//
//  Created by Juan.A.Roldan on 29/07/2025.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var firebaseUser: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var errorMessage = ""
    @Published var isLoading = false

    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var userListener: ListenerRegistration?

    init() {
        authStateHandle = auth.addStateDidChangeListener { [weak self] (_, user) in
            guard let self = self else { return }
            self.firebaseUser = user
            
            if let user = user {
                self.listenToUserData(userId: user.uid)
            } else {
                self.currentUser = nil
                self.userListener?.remove()
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            auth.removeStateDidChangeListener(handle)
        }
        userListener?.remove()
    }
    
    func listenToUserData(userId: String) {
        userListener?.remove()
        userListener = db.collection("users").document(userId).addSnapshotListener { [weak self] documentSnapshot, error in
            guard let self = self, let document = documentSnapshot, let data = document.data() else { return }
            self.currentUser = User(id: document.documentID, dictionary: data)
        }
    }
    
    func updateWeeklyChallenge(goalInKm: Double) {
            guard let userId = firebaseUser?.uid else { return }
            let goalInMeters = goalInKm * 1000
            
            // 1. Actualizamos Firebase
            db.collection("users").document(userId).updateData(["weeklyChallengeGoal": goalInMeters])
            
            // 2. --- CORRECCIÓN ---: Actualizamos el dato local INMEDIATAMENTE
            // Esto hace que la UI reaccione al instante sin esperar a Firebase
            if var user = self.currentUser {
                user.weeklyChallengeGoal = goalInMeters
                self.currentUser = user
            }
        } 

    func updateUserProfile(name: String, completion: @escaping (Bool) -> Void) {
        guard let userId = firebaseUser?.uid else { return }
        isLoading = true
        
        // Actualizamos solo el campo "name" en la colección users
        db.collection("users").document(userId).updateData(["name": name]) { [weak self] error in
            self?.isLoading = false
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
            } else {
                // Actualizamos el usuario localmente para que la UI cambie rápido
                self?.currentUser?.name = name
                completion(true)
            }
        }
    }

    func login(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        auth.signIn(withEmail: email, password: password) { [weak self] (_, error) in
            defer { self?.isLoading = false }
            if let error = error {
                self?.errorMessage = error.localizedDescription
            }
        }
    }

    func signUp(name: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
            print("🚀 [DEBUG] 1. Función signUp llamada. Email: \(email)")
            
            isLoading = true
            errorMessage = ""
            
            // Verificamos conexión básica antes de llamar a Firebase
            print("🚀 [DEBUG] 2. Llamando a Auth.auth().createUser...")
            
            auth.createUser(withEmail: email, password: password) { [weak self] (authResult, error) in
                guard let self = self else { return }
                
                // PRIMER PUNTO DE FALLO: RESPUESTA DE AUTH
                if let error = error {
                    print("❌ [ERROR CRÍTICO AUTH]: \(error.localizedDescription)")
                    print("❌ [CÓDIGO ERROR]: \((error as NSError).code)")
                    self.isLoading = false
                    self.errorMessage = "Error Auth: \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                guard let user = authResult?.user else {
                    print("❌ [ERROR] No hay error, pero tampoco usuario.")
                    self.isLoading = false
                    completion(false)
                    return
                }
                
                print("✅ [EXITO AUTH] Usuario creado en Auth: \(user.uid)")
                print("🚀 [DEBUG] 3. Intentando guardar en Firestore...")

                let userData: [String: Any] = [
                    "name": name,
                    "email": email,
                    "createdAt": Timestamp(),
                    "weeklyChallengeGoal": 0.0
                ]
                
                self.db.collection("users").document(user.uid).setData(userData) { error in
                    self.isLoading = false // Apagamos el spinner pase lo que pase
                    
                    // SEGUNDO PUNTO DE FALLO: RESPUESTA DE FIRESTORE
                    if let error = error {
                        print("❌ [ERROR CRÍTICO FIRESTORE]: \(error.localizedDescription)")
                        print("❌ [CÓDIGO ERROR]: \((error as NSError).code)")
                        self.errorMessage = "Error Base de Datos: \(error.localizedDescription)"
                        // AUNQUE FALLE FIRESTORE, EL USUARIO YA SE CREÓ EN AUTH.
                        // Devolvemos true para salir de la pantalla, o false si prefieres bloquear.
                        completion(true)
                    } else {
                        print("✅ [EXITO TOTAL] Usuario guardado en Firestore.")
                        completion(true)
                    }
                }
            }
        }
    
    func signOut() {
        do {
            try auth.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
