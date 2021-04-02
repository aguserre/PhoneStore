//
//  ProductTableViewCell.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 01/04/2021.
//

import UIKit

final class ProductTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backCellView: UIView!
    @IBOutlet weak var productNameLabel: UILabel!
    

    func setupCell(product: ProductModel) {
        productNameLabel.text = product.code?.capitalized
        backCellView.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        backCellView.layer.cornerRadius = 5
    }

}
