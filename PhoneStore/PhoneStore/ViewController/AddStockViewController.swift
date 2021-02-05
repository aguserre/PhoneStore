//
//  AddStockViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class AddStockViewController: UIViewController {

    var dataBaseRef: DatabaseReference!
    var selectedPos: PointOfSale?
    var userLogged: UserModel?
    let generator = UIImpactFeedbackGenerator(style: .medium)
    enum ProductTextFieldData: Int {
        case codeTextField = 0
        case colorTextField = 1
        case descTextField = 2
        case buyPriceTextField = 3
        case salePriceTextField = 4
    }
    var productDic = [String : Any]()
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var addButton: UIButton!
    
    //StackView
    @IBOutlet weak var backgroundCardView: UIView!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var cantitiStepper: UIStepper!
    @IBOutlet weak var colorTextField: UITextField!
    @IBOutlet weak var conditionSelector: UISwitch!
    @IBOutlet weak var cantitiLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var buyPriceTextField: UITextField!
    @IBOutlet weak var salePriceTextField: UITextField!
    @IBOutlet weak var backgroundConditionView: UIView!
    @IBOutlet weak var posSelectButton: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupTextfieldsDelegate()
        navigationItem.rightBarButtonItem = setupRightButton(target: #selector(logOut))
        dataBaseRef = Database.database().reference().child("PROD_ADD").childByAutoId()
        setupStepper()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        let gradientLayer3 = CAGradientLayer()
        gradientLayer3.frame = headerView.bounds
        gradientLayer3.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
        gradientLayer3.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer3.endPoint = CGPoint(x: 1.0, y: 0.5)
        headerView.layer.insertSublayer(gradientLayer3, at: 0)
        headerView.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        
        let gradientLayer4 = CAGradientLayer()
        gradientLayer4.frame = backgroundCardView.bounds
        gradientLayer4.cornerRadius = 10
        gradientLayer4.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
        gradientLayer4.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer4.endPoint = CGPoint(x: 1.0, y: 0.5)
        backgroundCardView.layer.insertSublayer(gradientLayer4, at: 0)
        
        addButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        backgroundCardView.layer.cornerRadius = 10
        backgroundCardView.addShadow(offset: .zero, color: .systemIndigo, radius: 4, opacity: 0.4)
        backgroundConditionView.layer.cornerRadius = 10
        posSelectButton.layer.cornerRadius = 10
        
        let gradientLayer2 = CAGradientLayer()
        gradientLayer2.frame = self.addButton.bounds
        gradientLayer2.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
        gradientLayer2.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer2.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.addButton.layer.insertSublayer(gradientLayer2, at: 0)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        dataBaseRef.removeAllObservers()
    }
    
    @IBAction func addProduct(_ sender: Any) {
        generator.impactOccurred()
        saveProduct()
    }
    
    func setupTextfieldsDelegate() {
        codeTextField.delegate = self
        colorTextField.delegate = self
        descriptionTextField.delegate = self
        buyPriceTextField.delegate = self
        salePriceTextField.delegate = self
    }
    
    func setupStepper() {
        cantitiStepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        
        guard let cost = Double(cantitiLabel.text!) else {
            print("The user entered a value price of")
            return
        }
        
        cantitiStepper.value = cost
    }
    
    @objc func stepperChanged() {
        cantitiLabel.text = String(format: "%.0f", cantitiStepper.value)
    }
    
    func saveProduct() {
        let date = Date()
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        let today = formatter1.string(from: date)
        let condition = conditionSelector.isOn ? "Usado" : "Nuevo"
        var priceBuy: Double = 0.00
        var saleBuy: Double = 0.00
        
        if let stringPrice = productDic["priceBuy"] as? String, let doublePrice = Double(stringPrice) {
            priceBuy = doublePrice
        }
        if let stringPrice = productDic["priceSale"] as? String, let doublePrice = Double(stringPrice) {
            saleBuy = doublePrice
        }

        let prodDic: [String : Any] =  ["id":selectedPos?.id as Any,
                                        "code" : productDic["code"] as Any,
                                        "description" : productDic["description"] as Any,
                                        "color" : productDic["color"] as Any,
                                        "condition" : condition,
                                        "priceBuy" : priceBuy,
                                        "priceSale" : saleBuy,
                                        "dateIn" : today,
                                        "dateOut" : "",
                                        "cantiti" : Int(cantitiLabel.text ?? "0") as Any,
                                        "localInStock" : selectedPos?.name as Any]

        let p = ProductModel(JSON: prodDic)
        dataBaseRef.setValue(p?.toDictionary()) { (error, ref) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let dic = p?.toDictionary() {
                    self.registerAddMov(dic: dic)
                }
            }
        }
    }
    
    func registerAddMov(dic: NSDictionary) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction @objc func logOut(_ sender: Any) {
        generator.impactOccurred()
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        
        navigationController?.popToRootViewController(animated: true)
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
