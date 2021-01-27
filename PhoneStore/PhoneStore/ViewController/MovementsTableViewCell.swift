//
//  MovementsTableViewCell.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 27/01/2021.
//

import UIKit

class MovementsTableViewCell: UITableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    

    func configure(mov: MovementsModel) {
        infoLabel.text = mov.productDescription
        typeLabel.text = mov.movementType
        
        typeLabel.textColor = typeLabel.text?.lowercased() == "venta" ? .red : .green
        
    }
    
}
