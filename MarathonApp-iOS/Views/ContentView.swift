//
//  ContentView.swift
//  MarathonApp-iOS
//
//  Created by Juan.A.Roldan on 29/07/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        if authVM.firebaseUser != nil {
            HomeView()
        } else {
            LoginView()
        }
    }
}
