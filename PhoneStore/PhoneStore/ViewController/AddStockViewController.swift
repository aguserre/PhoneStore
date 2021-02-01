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
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = setupRightButton(target: #selector(logOut))
        dataBaseRef = Database.database().reference().child("PROD_ADD").childByAutoId()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        addButton.layer.shadowPath = UIBezierPath(rect: addButton.bounds).cgPath
        addButton.layer.shadowRadius = 5
        addButton.layer.shadowOffset = .zero
        addButton.layer.shadowOpacity = 0.3
        
        let gradientLayer2 = CAGradientLayer()
        gradientLayer2.cornerRadius = 10
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
        saveProduct()
    }
    
    func saveProduct() {
        let date = Date()
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        let today = formatter1.string(from: date)
        let  ramdomPrice = String(Int.random(in: 1..<10000))
        let prodDic: [String : Any] =  ["id":selectedPos?.id as Any,
                                        "code" : "I_M \(String(Int.random(in: 1..<100)))",
                                        "description" : "Descripcion del producto",
                                        "color" : "Rojo" ,
                                        "condition" : "Usado",
                                        "priceBuy" : "142",
                                        "priceSale" : ramdomPrice,
                                        "dateIn" : today,
                                        "dateOut" : " ",
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
        
    }
    
    @IBAction @objc func logOut(_ sender: Any) {
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        
        navigationController?.popToRootViewController(animated: true)
    }
}
