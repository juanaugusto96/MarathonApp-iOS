//
//  RunManager.swift
//  MarathonApp-iOS
//
//  Created by Juan.A.Roldan on 29/07/2025.
//

import CoreLocation
import MapKit
import SwiftUI

class RunManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var elapsedTime: TimeInterval = 0
    @Published var distance: Double = 0.0
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var pathCoordinates: [CLLocationCoordinate2D] = []
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let locationManager = CLLocationManager()
    private var startDate: Date?
    private var pauseStartDate: Date?
    private var totalPausedTime: TimeInterval = 0
    private var previousLocation: CLLocation?
    private var timer: Timer?
    private var initialLocationSet = false
    
    private let authVM: AuthViewModel
    private let runVM: RunViewModel

    init(authVM: AuthViewModel, runVM: RunViewModel) {
        self.authVM = authVM
        self.runVM = runVM
        super.init()
        configureLocationManager()
    }

    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        authorizationStatus = locationManager.authorizationStatus
    }

    func checkAndRequestLocationPermission() {
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func startRunning() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            checkAndRequestLocationPermission()
            return
        }
        resetMetrics()
        isRunning = true
        isPaused = false
        startDate = Date()
        locationManager.startUpdatingLocation()
        startTimer()
    }

    func pauseRunning() {
        guard isRunning, !isPaused else { return }
        isPaused = true
        timer?.invalidate()
        pauseStartDate = Date()
    }

    func resumeRunning() {
        guard isRunning, isPaused, let pauseStart = pauseStartDate else { return }
        let pausedDuration = Date().timeIntervalSince(pauseStart)
        totalPausedTime += pausedDuration
        isPaused = false
        pauseStartDate = nil
        startTimer()
    }

    func stopRunning() {
        guard isRunning else { return }
        isRunning = false
        isPaused = false
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
        saveRun()
    }
    
    private func saveRun() {
        guard let userId = authVM.firebaseUser?.uid else { return }
        guard distance > 0 || elapsedTime > 0 else { return }
        
        let pathData = pathCoordinates.map { $0.coordinateData }
        let run = Run(id: nil, distance: distance, duration: elapsedTime, date: startDate ?? Date(), userId: userId, path: pathData)
        runVM.saveRun(run)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startDate, !self.isPaused else { return }
            self.elapsedTime = Date().timeIntervalSince(start) - self.totalPausedTime
        }
    }
    
    private func resetMetrics() {
        elapsedTime = 0
        distance = 0.0
        previousLocation = nil
        startDate = nil
        pathCoordinates.removeAll()
        totalPausedTime = 0
        pauseStartDate = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last, newLocation.horizontalAccuracy >= 0, newLocation.horizontalAccuracy <= 65 else { return }

        if !initialLocationSet {
            DispatchQueue.main.async { [weak self] in
                self?.region = MKCoordinateRegion(center: newLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self?.initialLocationSet = true
            }
        }

        guard isRunning, !isPaused else { return }

        pathCoordinates.append(newLocation.coordinate)
        
        if let previous = previousLocation {
            distance += newLocation.distance(from: previous)
        }
        previousLocation = newLocation
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

}
