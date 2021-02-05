//
//  ProductCardCollectionViewCell.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 03/02/2021.
//

protocol CantitiProductChanged : class {
    func cantitiChanged(cantiti: Double)
}

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
    @IBOutlet weak var backgroundCantitiView: UIView!
    @IBOutlet weak var cantitiStepper: UIStepper!
    @IBOutlet weak var cantitiLabel: UILabel!
    let generator = UIImpactFeedbackGenerator(style: .medium)
    var unityPrice: Double = 0.00
    var count = 0.00
    
    var delegate: CantitiProductChanged?
    
    func setup(product: ProductModel) {
        productName.text = product.code
        conditionLabel.text = product.condition
        descriptionLabel.text = product.description
        colorLabel.text = product.color
        
        count = cantitiStepper.value
        
        if let price = product.priceSale {
            unityPrice = price
            priceLabel.text = "$ \(price)"
        }
        
        if let date =  product.dateIn {
            dateInLabel.text =  date
        }
        
        if let cantiti = product.cantiti {
            cantitiStepper.maximumValue = Double(cantiti)
        }
        
        backgroundCantitiView.addShadow(offset: .zero, color: .systemTeal, radius: 3, opacity: 0.4)
        backgroundCantitiView.layer.cornerRadius = 13
        
        descriptionBackgroundView.layer.cornerRadius = 20
        descriptionBackgroundView.addShadow(offset: .zero, color: .systemTeal, radius: 4, opacity: 0.4)
        
        separatorView.layer.cornerRadius = separatorView.bounds.height/2
        separatorView.addShadow(offset: .zero, color: .systemTeal, radius: 4, opacity: 0.4)
        
        separatorBottomView.layer.cornerRadius = separatorBottomView.bounds.height/2
        separatorBottomView.addShadow(offset: .zero, color: .systemTeal, radius: 4, opacity: 0.4)
        
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true

        cantitiStepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
    }
    
    @objc func stepperChanged() {
        generator.impactOccurred()
        let total = unityPrice * cantitiStepper.value
        priceLabel.text = "$ \(String(total))"
        cantitiLabel.text = String(format: "%.0f", cantitiStepper.value)
        let totalWithSign = cantitiStepper.value > count ? unityPrice : -unityPrice
        
        count = cantitiStepper.value
        delegate?.cantitiChanged(cantiti: totalWithSign)
    }
}
