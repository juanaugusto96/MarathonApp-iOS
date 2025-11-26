//
//  CountDownView.swift
//  MarathonApp-iOS
//
//  Created by Juan.A.Roldan on 29/07/2025.
//

import SwiftUI

struct CountDownView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var runManager: RunManager
    @State private var countdown = 3
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            Text("\(countdown)")
                .font(.system(size: 150, weight: .bold)).foregroundColor(.white)
        }
        .onReceive(timer) { _ in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.upstream.connect().cancel()
                runManager.startRunning()
                dismiss()
            }
        }
    }
}
