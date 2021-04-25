//
//  EditCollectionViewCell.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 24/04/2021.
//

import UIKit

class EditCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    
    
    func setupCell(pos: PointOfSale) {
        nameLabel.text = pos.name?.capitalized
        let imageType: String = pos.type == POSType.kStatic.rawValue ? "house" : "car"
        typeImage.image = UIImage(systemName: imageType)
    }
    
}
