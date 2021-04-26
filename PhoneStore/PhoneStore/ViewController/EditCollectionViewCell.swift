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
        let imageType: String = pos.type == POSType.kStatic.rawValue ? "house.fill" : "car.fill"
        typeImage.image = UIImage(systemName: imageType)
    }
    
    func setupCell(user: UserModel) {
        nameLabel.text = user.email
        typeImage.image = UIImage(systemName: "person.crop.rectangle.fill")
    }
    
}
