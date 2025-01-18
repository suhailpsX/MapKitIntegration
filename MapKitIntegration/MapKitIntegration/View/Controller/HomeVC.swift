//
//  ViewController.swift
//  MapKitIntegration
//
//  Created by Suhail on 17/01/25.
//

import UIKit
import MapKit

class HomeVC: UIViewController {

    @IBOutlet private weak var mapTableView: UITableView!
    @IBOutlet private weak var toggleViewButton: UIButton!

    private let viewModel = HomeViewModel()
    private var isListViewEnabled = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadTasksFromStorage()
    }

    @IBAction private func toggleViewButtonTapped(_ sender: UIButton) {
        isListViewEnabled.toggle()
        updateToggleViewButtonTitle()
        mapTableView.reloadData()
    }

    private func setupUI() {
        mapTableView.delegate = self
        mapTableView.dataSource = self
        toggleViewButton.layer.cornerRadius = 12
        toggleViewButton.backgroundColor = .systemRed
        updateToggleViewButtonTitle()
    }

    private func updateToggleViewButtonTitle() {
        let title = isListViewEnabled ? "List View" : "Map View"
        toggleViewButton.setTitle(title, for: .normal)
    }

    private func bindViewModel() {
        viewModel.onTasksUpdated = { [weak self] in
            self?.mapTableView.reloadData()
        }

        viewModel.onLocationUpdated = { [weak self] in
            self?.mapTableView.reloadData()
        }
    }
}

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isListViewEnabled ? viewModel.tasks.count : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isListViewEnabled {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListMapLocationTCell", for: indexPath) as? ListMapLocationTCell else {
                return UITableViewCell()
            }
            let task = viewModel.tasks[indexPath.row]
            cell.configure(with: task)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewTCell", for: indexPath) as? MapViewTCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            if let userLocation = viewModel.userLocation {
                cell.configureMap(centerCoordinate: userLocation, annotations: viewModel.getTaskAnnotations())
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        isListViewEnabled ? UITableView.automaticDimension : 700
    }
}

extension HomeVC: MapViewTCellDelegate {
    func didLongPress(location: CLLocationCoordinate2D) {
        showTaskCreationAlert(for: location)
    }

    func didSelectAnnotation(task: User) {
        showTaskDetailsAlert(for: task)
    }

    private func showTaskCreationAlert(for location: CLLocationCoordinate2D) {
        let alert = UIAlertController(title: "Add Location", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Title" }
        alert.addTextField { $0.placeholder = "Description" }

        let addAction = UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            guard let title = alert.textFields?[0].text, !title.isEmpty,
                  let description = alert.textFields?[1].text, !description.isEmpty else { return }
            self?.viewModel.addTask(title: title, description: description, location: location)
        }

        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(alert, animated: true)
    }

    private func showTaskDetailsAlert(for task: User) {
        let alert = UIAlertController(title: task.title, message: "\(task.description)\nLatitude: \(task.location.latitude)\nLongitude: \(task.location.longitude)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
