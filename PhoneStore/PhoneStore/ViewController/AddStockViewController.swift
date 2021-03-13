//
//  AddStockViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit

final class AddStockViewController: UIViewController {

    var selectedPos: PointOfSale?
    var userLogged: UserModel?
    let serviceManager = ServiceManager()
    var isEmptyProductList = false
    var isExpanded = false
    enum ProductTextFieldData: Int {
        case codeTextField = 0
        case colorTextField = 1
        case descTextField = 2
        case buyPriceTextField = 3
        case salePriceTextField = 4
    }
    var productDic = [String : Any]()
    @IBOutlet private weak var addButton: UIButton!
    
    //StackView
    @IBOutlet private weak var backgroundCardView: UIView!
    @IBOutlet private weak var codeTextField: UITextField!
    @IBOutlet private weak var cantitiStepper: UIStepper!
    @IBOutlet private weak var colorTextField: UITextField!
    @IBOutlet private weak var conditionSelector: UISwitch!
    @IBOutlet private weak var cantitiLabel: UILabel!
    @IBOutlet private weak var descriptionTextField: UITextField!
    @IBOutlet private weak var buyPriceTextField: UITextField!
    @IBOutlet private weak var salePriceTextField: UITextField!
    @IBOutlet private weak var backgroundConditionView: UIView!
    @IBOutlet private weak var posSelectButton: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        hideKeyboardWhenTappedAround()
        setupTextfieldsDelegate()
        setNavTitle(title: "Nuevo producto")
        setupObservers()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        hideKeyboardWhenTappedAround()
    }
    
    @objc private func keyboardWillShow(notification:NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        if !isExpanded {
            self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + keyboardFrame.height/2)
            isExpanded = true
        }
        UIView.animate(withDuration: 0.3, delay: 0.5) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc private func keyboardWillHide(notification:NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height - keyboardFrame.height/2)
        isExpanded = false
        UIView.animate(withDuration: 1, delay: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupView() {
        navigationItem.rightBarButtonItem = setupRightButton(target: #selector(logOut))
        setupStepper()

        view.layer.insertSublayer(createCustomGradiend(view: view), at: 0)
        addButton.layer.insertSublayer(createCustomGradiend(view: addButton), at: 0)
        
        addButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        backgroundCardView.addShadow(offset: .zero, color: .systemIndigo, radius: 4, opacity: 0.4)
        
        backgroundCardView.layer.cornerRadius = 10
        backgroundConditionView.layer.cornerRadius = 10
        posSelectButton.layer.cornerRadius = 10
    }
    
    @IBAction func addProduct(_ sender: Any) {
        generateImpactWhenTouch()
        saveProduct()
    }
    
    func setupTextfieldsDelegate() {
        codeTextField.delegate = self
        colorTextField.delegate = self
        descriptionTextField.delegate = self
        buyPriceTextField.delegate = self
        salePriceTextField.delegate = self
    }
    
    private func setupStepper() {
        cantitiStepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        
        guard let cost = Double(cantitiLabel.text!) else {
            print("The user entered a value price of")
            return
        }
        
        cantitiStepper.value = cost
    }
    
    @objc private func stepperChanged() {
        cantitiLabel.text = String(format: "%.0f", cantitiStepper.value)
    }
    
    private func saveProduct() {
        if let pos = selectedPos, let cantiti = Int(cantitiLabel.text ?? "1") {
            serviceManager.saveProduct(productDic: productDic,
                                       condition: conditionSelector.isOn ? "Usado" : "Nuevo",
                                       saveToPOS: pos,
                                       cantiti: cantiti)
        }
    }
    
    @IBAction @objc private func logOut(_ sender: Any) {
        generateImpactWhenTouch()
        serviceManager.logOut(delegate: self)
    }
}

extension AddStockViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
    }
    
    @objc func valueChanged(_ textField: UITextField){
        switch textField.tag {
        case ProductTextFieldData.codeTextField.rawValue:
            productDic["code"] = textField.text
            textField.keyboardType = .alphabet
        case ProductTextFieldData.colorTextField.rawValue:
            productDic["color"] = textField.text
            textField.keyboardType = .alphabet
        case ProductTextFieldData.descTextField.rawValue:
            productDic["description"] = textField.text
            textField.keyboardType = .alphabet
        case ProductTextFieldData.buyPriceTextField.rawValue:
            productDic["priceBuy"] = textField.text
            textField.keyboardType = .decimalPad
        case ProductTextFieldData.salePriceTextField.rawValue:
            productDic["priceSale"] = textField.text
            textField.keyboardType = .decimalPad
        default:
            break
        }
        
        print(productDic)
    }
}
