//
//  DetailViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit
import Gemini

final class DetailViewController: UIViewController {

    var selectedProduct: ProductModel?
    var multipSelectedProducts = [ProductModel]()
    var userLogged: UserModel?
    let serviceManager = ServiceManager()
    @IBOutlet private weak var sellButton: UIButton!
    @IBOutlet private weak var prodCollectionView: GeminiCollectionView!
    var purchaseTotalAmount = 0.0
    let cellScale: CGFloat = 0.7
    var subtotal = 0.00

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        calculateTotal()
    }
    
    private func setupView() {
        navigationItem.rightBarButtonItem = setupRightButton(target: #selector(logOut))
        hideKeyboardWhenTappedAround()
        prodCollectionView.gemini
            .rollRotationAnimation()
            .degree(60)
            .rollEffect(.reverseSineWave)
        
        view.layer.insertSublayer(createCustomGradiend(view: view), at: 0)
        sellButton.layer.insertSublayer(createCustomGradiend(view: sellButton), at: 0)
        
        sellButton.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
    }
    
    @IBAction private func updateProduct(_ sender: Any) {
        generateImpactWhenTouch()
        serviceManager.updateProductCantiti(delegate: self,productsList: multipSelectedProducts, withTotalAmount: purchaseTotalAmount) { (error) in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "SuccessViewController") as! SuccessViewController
            if let _ = error {
                newViewController.result = .failure
            } else {
                newViewController.amount = self.purchaseTotalAmount
                newViewController.products = self.multipSelectedProducts
                newViewController.result = .success
            }
            
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
    }
    
    private func calculateTotal() {
        var total: Double = 0.0
        for product in multipSelectedProducts {
            if let price = product.priceSale {
                total = price + total
            }
        }
        subtotal = total
        setNavTitle(title: "Total $ \(total)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier,
           segueId == "goToModifStock",
           let modifViewController = segue.destination as? ModifiedStockViewController {
            modifViewController.product = selectedProduct
        }
    }
    
    @IBAction private func logOut(_ sender: Any) {
        generateImpactWhenTouch()
        serviceManager.logOut(delegate: self)
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
        let width = collectionView.bounds.width * cellScale
        let height = collectionView.bounds.height * cellScale
        
        let insetX = (collectionView.bounds.width - width)/2
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
        generateImpactWhenTouch()
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
        setNavTitle(title: "Total $ \(subtotal)")
    }
    
}
