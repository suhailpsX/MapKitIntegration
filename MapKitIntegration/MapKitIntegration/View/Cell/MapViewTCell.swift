//
//  MapViewTCell.swift
//  MapKitIntegration
//
//  Created by Suhail on 17/01/25.
//

import UIKit
import MapKit

protocol MapViewTCellDelegate {
    func didLongPress(location: CLLocationCoordinate2D)
    func didSelectAnnotation(task: Task)
}

class MapViewTCell: UITableViewCell {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var recenterButton: UIButton!
    var cellDelegate: MapViewTCellDelegate?
    
    private var isUserInteractingWithMap = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}

extension MapViewTCell: MKMapViewDelegate {
    private func setUpCell() {
        recenterButton.layer.cornerRadius = 10
        recenterButton.backgroundColor = .systemBlue
        
        mapView.layer.cornerRadius = 10
        mapView.showsUserLocation = true
        mapView.delegate = self

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let point = gesture.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        cellDelegate?.didLongPress(location: coordinate)
    }

    func configureMap(centerCoordinate: CLLocationCoordinate2D, annotations: [MKAnnotation]) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)

        // Only set the region if the user hasn't interacted with the map
        if !isUserInteractingWithMap {
            let region = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? MKPointAnnotation,
              let title = annotation.title,
              let subtitle = annotation.subtitle else { return }

        let task = Task(title: title ?? "", description: subtitle ?? "", location: annotation.coordinate)
        cellDelegate?.didSelectAnnotation(task: task)
    }

    // This delegate method is triggered when the user drags or zooms the map.
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        isUserInteractingWithMap = true
    }

    // This delegate method is triggered when the user stops interacting with the map.
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Reset flag when interaction ends.
        isUserInteractingWithMap = false
    }

    private func recenterMap() {
        guard let userLocation = mapView.userLocation.location else {
            print("User location is not available.")
            return
        }
        
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        print("Map recentered to user location: \(userLocation.coordinate)")
    }
}
