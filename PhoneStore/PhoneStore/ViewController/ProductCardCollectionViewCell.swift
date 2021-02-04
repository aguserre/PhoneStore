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
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.contentView.bounds
        gradientLayer.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        contentView.layer.insertSublayer(gradientLayer, at: 0)
        
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
    }
}
