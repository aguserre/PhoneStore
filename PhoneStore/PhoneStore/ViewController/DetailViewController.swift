//
//  DetailViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class DetailViewController: UIViewController {

    var selectedProduct: ProductModel?
    var dataBaseRef: DatabaseReference!
    @IBOutlet weak var sellButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = setupRightButton(target: #selector(logOut))
       
        self.hideKeyboardWhenTappedAround()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        sellButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        
        let gradientLayer2 = CAGradientLayer()
        gradientLayer2.cornerRadius = 10
        gradientLayer2.frame = self.sellButton.bounds
        gradientLayer2.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
        gradientLayer2.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer2.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.sellButton.layer.insertSublayer(gradientLayer2, at: 0)
        
    }
    
    @IBAction func deleteProduct(_ sender: Any) {
        dataBaseRef = Database.database().reference().child("PROD_ADD")
        dataBaseRef.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        if self.selectedProduct?.code == postDict["code"] as? String {
                            self.dataBaseRef.child(snap.key).removeValue(completionBlock: { (error, ref) in
                                if error != nil {
                                    print("Error: \(String(describing: error))")
                                    return
                                }
                                self.dataBaseRef.removeAllObservers()
                                self.registerSaleMov()
                            })
                        }
                    } else {
                        print("Zhenya: failed to convert")
                    }
                }
            }
        }
    }
    
    func registerSaleMov() {
       
    }
    
    @IBAction func logOut(_ sender: Any) {
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        
        navigationController?.popToRootViewController(animated: true)
    }
}
