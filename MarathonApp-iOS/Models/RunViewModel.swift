//
//  RunViewModel.swift
//  MarathonApp-iOS
//
//  Created by Juan.A.Roldan on 29/07/2025.
//

import FirebaseFirestore
import SwiftUI

class RunViewModel: ObservableObject {
    @Published var runs: [Run] = []
    @Published var isLoading = false
    @Published var weeklyProgressInMeters: Double = 0.0

    private let db = Firestore.firestore()
    private var runsListener: ListenerRegistration?

    func saveRun(_ run: Run) {
        db.collection("runs").addDocument(data: run.dictionary) { error in
            if let error = error {
                print("Error saving run: \(error.localizedDescription)")
            }
        }
    }

    func fetchRuns(userId: String) {
        stopListening()
        isLoading = true
        runsListener = db.collection("runs")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                self.isLoading = false
                self.runs = documents.compactMap { Run(id: $0.documentID, dictionary: $0.data()) }
                self.calculateWeeklyProgress(from: self.runs)
            }
    }
    
    private func calculateWeeklyProgress(from allRuns: [Run]) {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else {
            self.weeklyProgressInMeters = 0
            return
        }
        let recentRuns = allRuns.filter { $0.date >= startOfWeek }
        let totalDistance = recentRuns.reduce(0) { $0 + $1.distance }
        DispatchQueue.main.async {
            self.weeklyProgressInMeters = totalDistance
        }
    }

    func stopListening() {
        runsListener?.remove()
    }

    deinit {
        stopListening()
    }
}
