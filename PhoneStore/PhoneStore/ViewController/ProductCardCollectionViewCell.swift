//
//  ProductCardCollectionViewCell.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 03/02/2021.
//

import UIKit
import Gemini

class ProductCardCollectionViewCell: GeminiCell {
    
    @IBOutlet weak var productName: UILabel!
    
    
    func setup(product: ProductModel) {
        productName.text = product.code
        
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
    }
}
