//
//  ChartCollectionViewCell.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 14/02/2021.
//

import UIKit

class ChartCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var posName: UILabel!
    var barView: UIView!
    @IBOutlet weak var totalLabel: UILabel!
    
    func setupCell(name: String, total: CGFloat, maxAmount: Double) {
        if barView != nil {
            barView.removeFromSuperview()
        }
        barView = UIView()
        
        barView.backgroundColor = .random()
        contentView.addSubview(barView)
        barView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = barView.bottomAnchor.constraint(equalTo: posName.topAnchor)
        let verticalConstraint = barView.centerXAnchor.constraint(equalTo: posName.centerXAnchor)
        let topContraint = barView.topAnchor.constraint(greaterThanOrEqualTo: totalLabel.bottomAnchor)
        let widthConstraint = barView.widthAnchor.constraint(equalToConstant: 20)
        let heightConstraint = barView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint,topContraint, widthConstraint, heightConstraint])
        layoutIfNeeded()
        
        barView.layer.cornerRadius = 5
        barView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        barView.addShadow(offset: .zero, color: .black, radius: 2, opacity: 0.5)
        
        posName.text = name.capitalized
        totalLabel.text = "$ \(total)"
        totalLabel.lineBreakMode = .byCharWrapping
        let percent: Double
        
        let totalHeigth = contentView.frame.size.height - posName.frame.size.height - totalLabel.frame.size.height
        
        if Double(total) == maxAmount {
            percent = Double(totalHeigth)
        } else {
            percent = Double(total) * Double(totalHeigth) / maxAmount
        }

        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveLinear) {
            heightConstraint.constant = CGFloat(percent)
            self.layoutIfNeeded()
        }
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}
