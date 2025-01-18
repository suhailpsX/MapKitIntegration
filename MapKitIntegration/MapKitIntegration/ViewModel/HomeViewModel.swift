//
//  HomeViewModel.swift
//  MapKitIntegration
//
//  Created by Suhail on 17/01/25.
//

import CoreLocation
import MapKit

class HomeViewModel: NSObject, CLLocationManagerDelegate {
    private(set) var tasks: [Task] = []
    var userLocation: CLLocationCoordinate2D?
    var onTasksUpdated: (() -> Void)?
    var onLocationUpdated: (() -> Void)?
    private var locationManager: CLLocationManager = CLLocationManager()

    override init() {
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        print("Location Manager started")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            print("No location received")
            return
        }
        userLocation = location.coordinate
        print("User Location Updated: \(location.coordinate)")
        onLocationUpdated?()
    }

    func addTask(title: String, description: String, location: CLLocationCoordinate2D) {
        let newTask = Task(title: title, description: description, location: location)
        tasks.append(newTask)
        saveTasksLocally()
        print("Task added: \(title)")
        onTasksUpdated?()
    }

    func getTaskAnnotations() -> [MKAnnotation] {
        return tasks.map { task in
            let annotation = MKPointAnnotation()
            annotation.coordinate = task.location
            annotation.title = task.title
            annotation.subtitle = task.description
            return annotation
        }
    }

    func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "tasks"),
           let savedTasks = try? JSONDecoder().decode([Task].self, from: data) {
            self.tasks = savedTasks
            print("Tasks loaded: \(tasks.count)")
            onTasksUpdated?()
        }
    }

    private func saveTasksLocally() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: "tasks")
        }
    }
}
