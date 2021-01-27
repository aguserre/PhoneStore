//
//  ListTableViewCell.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var descLabel: UILabel!
    
    
    func configure(phone: PhoneModel) {
        descLabel.text = phone.model
    }
    
    func configure(accesorie: ReplacementModel) {
        descLabel.text = accesorie.descriptions
    }


}
