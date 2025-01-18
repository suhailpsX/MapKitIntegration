//
//  ListMapLocationTCell.swift
//  MapKitIntegration
//
//  Created by Suhail on 18/01/25.
//

import UIKit

class ListMapLocationTCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(with task: User) {
        titleLabel.text = task.title
        descriptionLabel.text = task.description
        latitudeLabel.text = String(format: "%.4f", task.location.latitude)
        longitudeLabel.text = String(format: "%.4f", task.location.longitude)
    }
    
}
