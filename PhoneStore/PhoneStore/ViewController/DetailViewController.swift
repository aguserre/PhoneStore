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
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var prodCollectionView: GeminiCollectionView!
    let cellScale: CGFloat = 0.6

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = setupRightButton(target: #selector(logOut))
        self.hideKeyboardWhenTappedAround()
        
        prodCollectionView.gemini
            .rollRotationAnimation()
            .degree(60)
            .rollEffect(.reverseSineWave)
        
        let screenSize = UIScreen.main.bounds
        let layout = prodCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let topPadd: CGFloat = 130
        let cellWidth = floor(screenSize.width * cellScale)
        let cellHight = floor(screenSize.height * cellScale)
        
        let insetX = (view.bounds.width - cellWidth)/2
        let insetY = (view.bounds.height - cellHight - topPadd)/2
        
        layout.itemSize = CGSize(width: cellWidth, height: cellHight)
        prodCollectionView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
        
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

extension DetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return multipSelectedProducts.count ?? 1
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.prodCollectionView.animateVisibleCells()
    }
    

    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCardCollectionViewCell", for: indexPath) as! ProductCardCollectionViewCell
        
        cell.setup(product: multipSelectedProducts[indexPath.row])
        self.prodCollectionView.animateCell(cell)
        
        cell.addShadow(offset: .zero, color: .black, radius: 6, opacity: 0.6)
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

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let layout = self.prodCollectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing

        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)

        offset = CGPoint(
          x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left + cellWidthIncludingSpacing / 2 - scrollView.bounds.size.width / 2,
          y: -scrollView.contentInset.top
        )

        targetContentOffset.pointee = offset
    }
    
    
}
