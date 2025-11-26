//
//  NotificationManager.swift
//  MarathonApp-iOS
//
//  Created by Juan.A.Roldan on 25/11/2025.
//

import UserNotifications

class NotificationManager {
    static let instance = NotificationManager() // Singleton
    
    // 1. Pedir permiso
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("Permiso de notificaciones: \(success)")
            }
        }
    }
    
    // 2. Programar notificación
    func scheduleNotification(title: String, subtitle: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = .default
        
        // Se dispara 1 segundo después de llamarla
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
