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
    let generator = UIImpactFeedbackGenerator(style: .medium)
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var prodCollectionView: GeminiCollectionView!
    @IBOutlet weak var totalLabel: UILabel!
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
    
    @IBAction func deleteProduct(_ sender: Any) {
        generator.impactOccurred()
        dataBaseRef = Database.database().reference().child("PROD_ADD")
        dataBaseRef.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        for prod in self.multipSelectedProducts {
                            if prod.code == postDict["code"] as? String {
                                self.dataBaseRef.child(snap.key).removeValue(completionBlock: { (error, ref) in
                                    if error != nil {
                                        print("Error: \(String(describing: error))")
                                        return
                                    }
                                    self.registerSaleMov()
                                })
                            }
                        }
                    } else {
                        print("Zhenya: failed to convert")
                    }
                }
            }
        }
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
    
    func registerSaleMov() {
        navigationController?.popViewController(animated: true)
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
    func cantitiChanged(cantiti: Double) {
        updateValues(newAmount: cantiti)
    }
    
    func updateValues(newAmount: Double) {
        subtotal = subtotal + newAmount
        totalLabel.text = "Total $ \(subtotal)"
    }
    
}
