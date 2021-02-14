//
//  ChartCollectionViewCell.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 14/02/2021.
//

import UIKit

class ChartCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var posName: UILabel!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var barHeigthConstraint: NSLayoutConstraint!
    
    func setupCell(name: String, total: CGFloat) {
        posName.text = name
        barHeigthConstraint.constant = total
    }
}
