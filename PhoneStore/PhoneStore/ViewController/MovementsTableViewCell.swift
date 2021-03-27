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
        totalAmountMovementLabel.isHidden = mov.movementType == MovementType.rma.rawValue
        var imageName: String {
            switch mov.movementType {
            case "out":
                return "arrow.up"
            case "in":
                return "arrow.down"
            default:
                return "archivebox"
            }
        }
        var colorImage: UIColor {
            switch mov.movementType {
            case "out":
                return .red
            case "in":
                return .green
            default:
                return .gray
            }
        }
        imageTypeLabel.image = UIImage(systemName: imageName)
        imageTypeLabel.tintColor = colorImage
    }
    
}
