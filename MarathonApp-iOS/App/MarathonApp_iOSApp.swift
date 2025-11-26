//
//  MarathonApp_iOSApp.swift
//  MarathonApp-iOS
//
//  Created by Juan.A.Roldan on 29/07/2025.
//

import SwiftUI
import Firebase

@main
struct TheRunBoysApp: App {
    @StateObject private var authVM: AuthViewModel
    @StateObject private var runVM: RunViewModel
    @StateObject private var runManager: RunManager

    init() {
        FirebaseApp.configure()
        
        let authViewModel = AuthViewModel()
        let runViewModel = RunViewModel()
        
        NotificationManager.instance.requestAuthorization()
        
        _authVM = StateObject(wrappedValue: authViewModel)
        _runVM = StateObject(wrappedValue: runViewModel)
        _runManager = StateObject(wrappedValue: RunManager(authVM: authViewModel, runVM: runViewModel))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
                .environmentObject(runVM)
                .environmentObject(runManager)
        }
    }
}
