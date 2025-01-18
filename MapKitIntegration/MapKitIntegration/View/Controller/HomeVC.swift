//
//  ViewController.swift
//  MapKitIntegration
//
//  Created by Suhail on 17/01/25.
//

import UIKit
import MapKit
class HomeVC: UIViewController {

    @IBOutlet weak var mapTableView: UITableView!
    @IBOutlet weak var viewListButton: UIButton!
    
    var viewModel = HomeViewModel()
    var isToggle: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapTableView.delegate = self
        mapTableView.dataSource = self
        viewListButton.layer.cornerRadius = 12
        
        viewListButton.backgroundColor = .systemRed
        updateViewModel()
        viewModel.loadTasks()
    }

    @IBAction func viewListButtonTap(_ sender: Any) {
        if !isToggle {
            isToggle = true
            viewListButton.setTitle( "List View", for: .normal)
        } else {
            isToggle = false
            viewListButton.setTitle( "View Map", for: .normal)
        }
        mapTableView.reloadData()
    }
    
}

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isToggle {
            return 1
        } else {
            return viewModel.tasks.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isToggle {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewTCell", for: indexPath) as? MapViewTCell else { return UITableViewCell() }
            cell.cellDelegate = self
            if let userLocation = viewModel.userLocation {
                print("Configuring map with user location and annotations")
                cell.configureMap(centerCoordinate: userLocation, annotations: viewModel.getTaskAnnotations())
            } else {
                print("User location is nil during cell configuration")
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListMapLocationTCell", for: indexPath) as? ListMapLocationTCell else { return UITableViewCell() }
            cell.titleLabel.text = viewModel.tasks[indexPath.row].title
            cell.descriptionLabel.text = viewModel.tasks[indexPath.row].description
            cell.latitudeLabel.text = "\(viewModel.tasks[indexPath.row].location.latitude)"
            cell.longitudeLabel.text = "\(viewModel.tasks[indexPath.row].location.longitude)"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !isToggle {
            return 700
        } else  {
            return UITableView.automaticDimension
        }
    }
    
}

extension HomeVC: MapViewTCellDelegate {
    func didLongPress(location: CLLocationCoordinate2D) {
        let alert = UIAlertController(title: "Add Task", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Title" }
        alert.addTextField { $0.placeholder = "Description" }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let title = alert.textFields?[0].text, !title.isEmpty,
                  let description = alert.textFields?[1].text, !description.isEmpty else { return }
            
            self?.viewModel.addTask(title: title, description: description, location: location)
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func didSelectAnnotation(task: User) {
        let alert = UIAlertController(title: task.title, message: "\(task.description) \n LAT :\(task.location.latitude)\n LON : \(task.location.longitude)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension HomeVC {
    private func updateViewModel() {
        viewModel.onTasksUpdated = { [weak self] in
            DispatchQueue.main.async {
                print("Tasks updated, reloading table")
                self?.mapTableView.reloadData()
            }
        }
        
        viewModel.onLocationUpdated = { [weak self] in
            DispatchQueue.main.async {
                if let userLocation = self?.viewModel.userLocation {
                    print("User location updated: \(userLocation)")
                    self?.mapTableView.reloadData()
                } else {
                    print("User location is still nil, waiting for update")
                }
            }
        }
    }
}
