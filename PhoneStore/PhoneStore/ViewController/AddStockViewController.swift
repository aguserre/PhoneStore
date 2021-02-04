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
        
        addButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        
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
        generator.impactOccurred()
        saveProduct()
    }
    
    func saveProduct() {
        let date = Date()
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        let today = formatter1.string(from: date)
        let  ramdomPriceBuy = Double.random(in: 1..<10000)
        let roundPriceBuy = Double(round(100*ramdomPriceBuy)/100)
        
        let  ramdomPriceSale = Double.random(in: 1..<10000)
        let roundPriceSale = Double(round(100*ramdomPriceSale)/100)
        
        let prodDic: [String : Any] =  ["id":selectedPos?.id as Any,
                                        "code" : "I_M \(String(Int.random(in: 1..<100)))",
                                        "description" : "Descripcion del producto",
                                        "color" : "Rojo" ,
                                        "condition" : "Usado",
                                        "priceBuy" : roundPriceBuy,
                                        "priceSale" : roundPriceSale,
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
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction @objc func logOut(_ sender: Any) {
        generator.impactOccurred()
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        
        navigationController?.popToRootViewController(animated: true)
    }
}
