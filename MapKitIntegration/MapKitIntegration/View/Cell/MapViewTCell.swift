//
//  MapViewTCell.swift
//  MapKitIntegration
//
//  Created by Suhail on 17/01/25.
//

import UIKit
import MapKit

protocol MapViewTCellDelegate: AnyObject {
    func didLongPress(location: CLLocationCoordinate2D)
    func didSelectAnnotation(task: User)
}

class MapViewTCell: UITableViewCell {

    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var recenterButton: UIButton!

    weak var delegate: MapViewTCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }

    @IBAction private func recenterButtonTapped(_ sender: UIButton) {
        recenterMapToUserLocation()
    }

    private func configureCell() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        recenterButton.layer.cornerRadius = 10
        recenterButton.backgroundColor = .systemBlue

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressGesture)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let point = gesture.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        delegate?.didLongPress(location: coordinate)
    }

    func configureMap(centerCoordinate: CLLocationCoordinate2D, annotations: [MKAnnotation]) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
        let region = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }

    private func recenterMapToUserLocation() {
        guard let userLocation = mapView.userLocation.location else { return }
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
}

extension MapViewTCell: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? MKPointAnnotation else { return }
        let task = User(title: annotation.title ?? "", description: annotation.subtitle ?? "", location: annotation.coordinate)
        delegate?.didSelectAnnotation(task: task)
    }
}
