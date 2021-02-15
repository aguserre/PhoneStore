//
//  MovementsTableViewCell.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 27/01/2021.
//

import UIKit

class MovementsTableViewCell: UITableViewCell {

    @IBOutlet weak var imageTypeLabel: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalAmountMovementLabel: UILabel!
    

    func configure(mov: MovementsModel) {
        infoLabel.text = mov.code
        typeLabel.text = mov.localId?.capitalized
        dateLabel.text = mov.dateOut
        totalAmountMovementLabel.text = "$\(mov.totalAmount ?? 0)"
        let imageName = mov.movementType == "out" ? "arrow.up" : "arrow.down"
        let colorImage: UIColor = mov.movementType == "out" ? .red : .green
        imageTypeLabel.image = UIImage(systemName: imageName)
        imageTypeLabel.tintColor = colorImage
    }
    
}
