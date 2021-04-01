//
//  ModifiedStockViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 08/02/2021.
//

import UIKit

final class ModifiedStockViewController: UIViewController {

    @IBOutlet private weak var viewHeigthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var backView: UIView!
    @IBOutlet private weak var productTitleLabel: UILabel!
    @IBOutlet private weak var productCantitiLabel: UILabel!
    @IBOutlet private weak var stockToAddLabel: UILabel!
    @IBOutlet private weak var actualPriceBuyLabel: UILabel!
    @IBOutlet private weak var actualPriceSaleLabel: UILabel!
    @IBOutlet private weak var newPriceBuyTextField: UITextField!
    @IBOutlet private weak var newProceSaleTextField: UITextField!
    @IBOutlet private weak var stepperCantiti: UIStepper!
    @IBOutlet private weak var addButton: UIButton!
    
    private let serviceManager = ServiceManager()
    var product: ProductModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        setupObservers()
        stepperCantiti.value = 0
        if let productName = product?.code {
            productTitleLabel.text = productName
        }
        productCantitiLabel.text = String(product?.cantiti ?? 0)
        actualPriceBuyLabel.text = String(product?.priceBuy ?? 0)
        actualPriceSaleLabel.text = String(product?.priceSale ?? 0)
        stepperCantiti.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        backView.addShadow(offset: .zero, color: .systemIndigo, radius: 4, opacity: 0.4)
        backView.layer.cornerRadius = 20
        backView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        backView.clipsToBounds = true
        addButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        viewHeigthConstraint.constant = view.bounds.height/2
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        hideKeyboardWhenTappedAround()
    }
    
    @objc private func stepperChanged(_ sender: Any) {
        stockToAddLabel.text = String(format: "%.0f", stepperCantiti.value)
    }
    
    @IBAction private func update(_ sender: Any) {
        var anyWasModified = false
        if let pb = newPriceBuyTextField.text, let pbD = Double(pb) {
            anyWasModified = true
            product?.priceBuy = pbD
        }
        if let ps = newProceSaleTextField.text, let psD = Double(ps) {
            anyWasModified = true
            product?.priceSale = psD
        }
        let cantitiToAdd = Int(self.stepperCantiti.value)
        
        if cantitiToAdd > 0 {
            anyWasModified = true
        }
        
        if anyWasModified {
        if let actualCantiti = product?.cantiti {
            product?.cantiti = actualCantiti + cantitiToAdd
            product?.cantitiToSell = cantitiToAdd
        }
            serviceManager.updateCantiti(delegate: self, product: product)
        } else {
            presentAlertController(title: "Nada que modificar", message: "", delegate: self) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    @objc private func keyboardWillShow(notification:NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        UIView.animate(withDuration: 0.3, delay: 0.3) {
            self.viewHeigthConstraint.constant = self.view.bounds.height
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc private func keyboardWillHide(notification:NSNotification){
        UIView.animate(withDuration: 0.3, delay: 0.3) {
            self.viewHeigthConstraint.constant = self.view.bounds.height/2
            self.view.layoutIfNeeded()
        }
    }
}
