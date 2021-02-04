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
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var descriptionBackgroundView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var separatorBottomView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dateInLabel: UILabel!
    
    func setup(product: ProductModel) {
        productName.text = product.code
        conditionLabel.text = product.condition
        descriptionLabel.text = product.description
        colorLabel.text = product.color
        if let price = product.priceSale {
            priceLabel.text = "$ \(price)"
        }
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        if let date =  product.dateIn {
            formatter1.dateStyle = .short
            dateInLabel.text = formatter1.string(from: date)
        }
        
        descriptionBackgroundView.layer.cornerRadius = 20
        descriptionBackgroundView.addShadow(offset: .zero, color: .systemTeal, radius: 4, opacity: 0.4)
        
        separatorView.layer.cornerRadius = separatorView.bounds.height/2
        separatorView.addShadow(offset: .zero, color: .systemTeal, radius: 4, opacity: 0.4)
        
        separatorBottomView.layer.cornerRadius = separatorBottomView.bounds.height/2
        separatorBottomView.addShadow(offset: .zero, color: .systemTeal, radius: 4, opacity: 0.4)
        
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
    }
}
