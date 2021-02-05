//
//  ListTableViewCell.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

protocol CheckMarkDelegate : class {
    func didCheckBoxTapped(productAdd: ProductModel)
    func didDeselectCheck(productAdd: ProductModel)
}

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var checkView: UIView!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var cantitiLabel: UILabel!
    
    var productSelected: ProductModel!
    var id = ""
    var isChecked = false
    let largeConfig = UIImage.SymbolConfiguration(weight: .heavy)
    
    var delegate: CheckMarkDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSkeleton()
    }
    
    func configure(product: ProductModel) {
        checkView.addShadow(offset: .zero, color: .white, radius: 4, opacity: 0.4)
        checkView.backgroundColor = .systemIndigo
        let price = "$ \(product.priceSale ?? 0.0)"
        checkView.layer.cornerRadius = checkView.bounds.width/2
        checkView.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        codeLabel.text = product.code
        descLabel.text = product.description
        conditionLabel.text = product.condition
        priceLabel.adjustsFontSizeToFitWidth = true
        priceLabel.minimumScaleFactor = 0.2
        priceLabel.text = price
        cantitiLabel.text = "\(product.cantiti ?? 0)"
        id = product.code ?? ""
        isChecked = product.isChecked
        let imageName = isChecked ? "checkmark" : ""
        checkBoxButton.setImage(UIImage(systemName: imageName, withConfiguration: largeConfig), for: .normal)
        productSelected = product
    }
    
    func setupSkeleton() {
        
    }
    
    @IBAction func checkBoxTapped(_ sender: UIButton) {
        isChecked.toggle()
        
        if isChecked {
            checkBoxButton.setImage(UIImage(systemName: "checkmark", withConfiguration: largeConfig), for: .normal)
            delegate?.didCheckBoxTapped(productAdd: productSelected)
        } else {
            checkBoxButton.setImage(UIImage(systemName: ""), for: .normal)
            delegate?.didDeselectCheck(productAdd: productSelected)
        }
    }
}
