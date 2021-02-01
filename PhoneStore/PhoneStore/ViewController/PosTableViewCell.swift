//
//  PosTableViewCell.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 31/01/2021.
//

import UIKit

class PosTableViewCell: UITableViewCell {

    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var posTitleNameLabel: UILabel!
    @IBOutlet weak var locateLabel: UILabel!
    @IBOutlet weak var respLabel: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var imageTitle: UILabel!
    
    
    
    func setupPosCell(pos: PointOfSale, resp: String) {
        posTitleNameLabel.text = pos.name
        locateLabel.text = pos.localized
        respLabel.text = resp
        let imageType: String = pos.type == POSType.kStatic.rawValue ? "house" : "car"
        typeImage.image = UIImage(systemName: imageType)
        imageTitle.text = pos.type?.capitalized
    }

}
