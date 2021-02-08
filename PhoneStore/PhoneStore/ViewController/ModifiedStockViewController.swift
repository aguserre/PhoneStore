//
//  ModifiedStockViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 08/02/2021.
//

import UIKit
import FirebaseDatabase

class ModifiedStockViewController: UIViewController {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productCantitiLabel: UILabel!
    @IBOutlet weak var stockToAddLabel: UILabel!
    @IBOutlet weak var stepperCantiti: UIStepper!
    @IBOutlet weak var addButton: UIButton!
    
    var dataBaseRef: DatabaseReference!
    var product: ProductModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataBaseRef = Database.database().reference().child("PROD_ADD")
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
    
    override func viewWillDisappear(_ animated: Bool) {
        if dataBaseRef != nil {
            dataBaseRef.removeAllObservers()
        }
    }
    
    @objc func stepperChanged(_ sender: Any) {
        stockToAddLabel.text = String(format: "%.0f", stepperCantiti.value)
    }
    
    @IBAction func update(_ sender: Any) {
        if let productId = product?.productId {
            var totalCant: Int = 0
            if let actualCantiti = product?.cantiti {
                totalCant = Int(stepperCantiti.value) + actualCantiti
            }
            
            let newCantiti = ["cantiti": totalCant]
            dataBaseRef.child(productId).updateChildValues(newCantiti) { (error, ref) in
                if error != nil {
                    print("Imposible actualizar la cantidad de stock en este momento")
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
