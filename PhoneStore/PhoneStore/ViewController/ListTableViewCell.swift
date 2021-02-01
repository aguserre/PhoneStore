//
//  ListTableViewCell.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    func configure(product: ProductModel) {
        let price = "$ " + (product.priceSale ?? "0,00")
        codeLabel.text = product.code
        descLabel.text = product.description
        conditionLabel.text = product.condition
        priceLabel.text = price
    }

}
