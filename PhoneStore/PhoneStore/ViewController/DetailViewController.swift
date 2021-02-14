//
//  DetailViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Gemini

class DetailViewController: UIViewController {

    var selectedProduct: ProductModel?
    var multipSelectedProducts = [ProductModel]()
    var dataBaseRef: DatabaseReference!
    var userLogged: UserModel?
    let generator = UIImpactFeedbackGenerator(style: .medium)
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var prodCollectionView: GeminiCollectionView!
    @IBOutlet weak var totalLabel: UILabel!
    var purchaseTotalAmount = 0.0
    let cellScale: CGFloat = 0.7
    var subtotal = 0.00

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = setupRightButton(target: #selector(logOut))
        self.hideKeyboardWhenTappedAround()
        prodCollectionView.gemini
            .rollRotationAnimation()
            .degree(60)
            .rollEffect(.reverseSineWave)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        sellButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        
        let gradientLayer2 = CAGradientLayer()
        gradientLayer2.frame = self.sellButton.bounds
        gradientLayer2.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
        gradientLayer2.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer2.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.sellButton.layer.insertSublayer(gradientLayer2, at: 0)
        
        let gradientLayer3 = CAGradientLayer()
        gradientLayer3.frame = self.headerView.bounds
        gradientLayer3.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
        gradientLayer3.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer3.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.headerView.layer.insertSublayer(gradientLayer3, at: 0)
        headerView.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        calculateTotal()
}
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if dataBaseRef != nil {
            dataBaseRef.removeAllObservers()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Volvi de modificar stock")
    }
    
    @IBAction func deleteProduct(_ sender: Any) {
        generator.impactOccurred()
        dataBaseRef = Database.database().reference().child("PROD_ADD")
        dataBaseRef.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        for prod in self.multipSelectedProducts {
                            
                            if prod.code == postDict["code"] as? String,
                               let cantiti = postDict["cantiti"] as? Int {
                                if cantiti == prod.cantitiToSell {
                                    self.deleteProduct(key: snap.key, prod: prod)
                                } else {
                                    self.updateProductCantiti(key: snap.key, newCantiti: cantiti - prod.cantitiToSell, prod: prod)
                                }
                            }
                        }
                    } else {
                        print("Zhenya: failed to convert")
                    }
                }
            }
        }
    }
    
    func deleteProduct(key: String, prod: ProductModel) {
        print("Se quedo sin stock del producto \(key)")
        self.dataBaseRef.child(key).removeValue(completionBlock: { (error, ref) in
            if error != nil {
                print("Error: \(String(describing: error))")
                return
            }
            self.registerSaleMov(prod: prod, movType: .out)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func updateProductCantiti(key: String, newCantiti: Int, prod: ProductModel) {
//        print("Se actualiza el stock del producto \(key), por una cantidad de \(newCantiti)")
//        let post = ["cantiti": newCantiti]
//
//        self.dataBaseRef.child(key).updateChildValues(post) { (error, ref) in
//            if error != nil {
//                print("Imposible actualizar la cantidad")
//            }
        self.registerSaleMov(prod: prod, movType: .out)
            //self.dismiss(animated: true, completion: nil)
//    }
    }
    
    func calculateTotal() {
        var total: Double = 0.0
        for product in multipSelectedProducts {
            if let price = product.priceSale {
                total = price + total
            }
        }
        subtotal = total
        totalLabel.text = "Total $ \(total)"
    }
    
    func registerSaleMov(prod: ProductModel, movType: MovementType) {
        dataBaseRef = Database.database().reference().child("PROD_MOV").childByAutoId()
        let mov = generateMovment(prod: prod, movType: movType, amount: purchaseTotalAmount)
        dataBaseRef.setValue(mov?.toDictionary()) { (error, ref) in
            print("Success register out mov")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier,
           segueId == "goToModifStock",
           let modifViewController = segue.destination as? ModifiedStockViewController {
            modifViewController.product = selectedProduct
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        generator.impactOccurred()
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        
        navigationController?.popToRootViewController(animated: true)
    }
}

extension DetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return multipSelectedProducts.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.prodCollectionView.animateVisibleCells()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCardCollectionViewCell", for: indexPath) as! ProductCardCollectionViewCell
        
        cell.setup(product: multipSelectedProducts[indexPath.row])
        self.prodCollectionView.animateCell(cell)
        
        cell.addShadow(offset: .zero, color: .systemIndigo, radius: 6, opacity: 0.6)
        cell.delegate = self
        cell.layer.cornerRadius = 10
        
        return cell
    }
}

extension DetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ProductCardCollectionViewCell {
            self.prodCollectionView.animateCell(cell)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedProduct = multipSelectedProducts[indexPath.row]
        if userLogged?.type == UserType.admin.rawValue {
            performSegue(withIdentifier: "goToModifStock", sender: nil)
        }
    }
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.bounds.width * cellScale
        let height = collectionView.bounds.height * cellScale
        
        let insetX = (collectionView.bounds.width - width)/2 + 10
        let insetY = (collectionView.bounds.height - height)/2
        
        collectionView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
        
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        generator.impactOccurred()
    }
    
    
}

extension DetailViewController: CantitiProductChanged {
    func cantitiChanged(newAmount: Double, cantiti: Int, key: String) {
        for p in 0..<multipSelectedProducts.count {
            if multipSelectedProducts[p].productId == key {
                multipSelectedProducts[p].cantitiToSell = cantiti
            }
        }
        updateValues(newAmount: newAmount)
    }
    
    func updateValues(newAmount: Double) {
        subtotal = subtotal + newAmount
        purchaseTotalAmount = subtotal
        totalLabel.text = "Total $ \(subtotal)"
    }
    
}

extension UIViewController {
    func generateMovment(prod: ProductModel, movType: MovementType, amount: Double) -> MovementsModel? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd"
        
        
        
        let movDic = ["id": prod.id  ?? "",
                      "productDescription": prod.description ?? "",
                      "movementType": movType.rawValue,
                      "localId": prod.localInStock as Any,
                      "code" : prod.code as Any,
                      "condition" : prod.condition as Any,
                      "totalAmount" : amount as Any,
                      "dateOut" : dateFormatter.string(from: Date()),
                      "cantitiPurchase" : prod.cantitiToSell as Any]
        guard let mov = MovementsModel(JSON: movDic) else {
            return nil
        }
        return mov
    }
}
