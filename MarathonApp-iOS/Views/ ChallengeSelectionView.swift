//
//   ChallengeSelectionView.swift
//  MarathonApp-iOS
//
//  Created by Juan.A.Roldan on 29/07/2025.
//

import SwiftUI

struct ChallengeSelectionView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    private let challenges: [Double] = [20, 40, 60]
    
    var body: some View {
        NavigationView {
            ZStack{
                LinearGradient(
                    gradient: Gradient(colors: [
                        .black,
                        Color(white: 0.3),
                        Color(white: 0.5)
                    ]),
                    startPoint: .bottomTrailing,
                    endPoint: .zero
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Elige tu Desafío Semanal").font(.largeTitle).fontWeight(.bold).padding(.bottom, 30)
                        .foregroundColor(Color(red:0.1,green:0.6,blue:0.1))
                    ForEach(challenges, id: \.self) { challengeKm in
                        Button {
                            authVM.updateWeeklyChallenge(goalInKm: challengeKm)
                            dismiss()
                        } label: {
                            Text("\(Int(challengeKm)) km / semana").font(.title2).fontWeight(.semibold).frame(maxWidth: .infinity)
                                .padding().background(Color(red: 0.1, green: 1.5, blue: 0.1)).foregroundColor(Color(red:0.3,green:0.2,blue:0.6)).cornerRadius(12)
                        }
                    }
       
                    
                    Spacer()
                }
                .padding().navigationBarTitle("Desafíos", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") {
                            dismiss()
                        }
                        .tint(.black)
                    }
                }
            }
        }
    }
    
 }
  #Preview {
    ChallengeSelectionView()
}
