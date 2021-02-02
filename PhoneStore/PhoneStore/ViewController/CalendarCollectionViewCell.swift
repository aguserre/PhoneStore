//
//  CalendarCollectionViewCell.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 02/02/2021.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    
    func setupCell(day: Int) {
        dateLabel.text = String(day)
    }
    
}
