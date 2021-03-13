//
//  ModifiedStockViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 08/02/2021.
//

import UIKit

final class ModifiedStockViewController: UIViewController {

    @IBOutlet private weak var backView: UIView!
    @IBOutlet private weak var productTitleLabel: UILabel!
    @IBOutlet private weak var productCantitiLabel: UILabel!
    @IBOutlet private weak var stockToAddLabel: UILabel!
    @IBOutlet private weak var stepperCantiti: UIStepper!
    @IBOutlet private weak var addButton: UIButton!
    
    private let serviceManager = ServiceManager()
    var product: ProductModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        stepperCantiti.value = 0
        if let productName = product?.code {
            productTitleLabel.text = productName
        }
        productCantitiLabel.text = String(product?.cantiti ?? 0)
        stepperCantiti.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        backView.addShadow(offset: .zero, color: .systemIndigo, radius: 4, opacity: 0.4)
        backView.layer.cornerRadius = 20
        backView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        backView.clipsToBounds = true
        addButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
    }
    
    @objc private func stepperChanged(_ sender: Any) {
        stockToAddLabel.text = String(format: "%.0f", stepperCantiti.value)
    }
    
    @IBAction private func update(_ sender: Any) {
        serviceManager.updateCantiti(delegate: self, product: self.product, newCantiti: Int(self.stepperCantiti.value))
    }
        
}
