//
//  HomeViewModel.swift
//  MapKitIntegration
//
//  Created by Suhail on 17/01/25.
//

import CoreLocation
import MapKit

class HomeViewModel: NSObject, CLLocationManagerDelegate {
    private(set) var tasks: [User] = []
    var userLocation: CLLocationCoordinate2D?
    var onTasksUpdated: (() -> Void)?
    var onLocationUpdated: (() -> Void)?
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        configureLocationManager()
    }

    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        userLocation = location.coordinate
        onLocationUpdated?()
    }

    func addTask(title: String, description: String, location: CLLocationCoordinate2D) {
        let newTask = User(title: title, description: description, location: location)
        tasks.append(newTask)
        saveTasksToStorage()
        onTasksUpdated?()
    }

    func getTaskAnnotations() -> [MKPointAnnotation] {
        tasks.map { task in
            let annotation = MKPointAnnotation()
            annotation.coordinate = task.location
            annotation.title = task.title
            annotation.subtitle = task.description
            return annotation
        }
    }

    func loadTasksFromStorage() {
        if let data = UserDefaults.standard.data(forKey: "tasks"),
           let savedTasks = try? JSONDecoder().decode([User].self, from: data) {
            tasks = savedTasks
            onTasksUpdated?()
        }
    }

    private func saveTasksToStorage() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: "tasks")
        }
    }
}
