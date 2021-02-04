//
//  ListViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


class ListViewController: UIViewController {
    
    var products = [ProductModel]()
    var productsSelected = [ProductModel]()
    var productsFilter = [ProductModel]()
    
    var selectedPos: PointOfSale?
    var userLogged: UserModel?
    let generator = UIImpactFeedbackGenerator(style: .medium)
    var selectedProduct: ProductModel?
    @IBOutlet weak var backgroundHeaderView: UIView!
    
    var isSearching = false
    var dataBaseRef: DatabaseReference!
    var isKeyboardShowing = false
    @IBOutlet weak var cartButton: UIButton!
    @IBOutlet weak var cantSelectedLabel: UILabel!
    @IBOutlet weak var changeFilterButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if products.count != 0 {
            products.removeAll()
            cantSelectedLabel.isHidden = true
        }
        if productsSelected.count != 0 {
            productsSelected.removeAll()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        refreshData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        navigationItem.rightBarButtonItem = setupRightButton(target: #selector(logOut))
        let string = selectedPos?.name?.capitalized ?? "Stock"
        
        cantSelectedLabel.isHidden = true
        cantSelectedLabel.backgroundColor = .systemIndigo
        cantSelectedLabel.layer.cornerRadius = cantSelectedLabel.bounds.width/2
        cantSelectedLabel.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        
        let titleLbl = UILabel()
            let titleLblColor = UIColor.white

        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 20)!,
                                                         NSAttributedString.Key.foregroundColor: titleLblColor]

        titleLbl.attributedText = NSAttributedString(string: string, attributes: attributes)
        titleLbl.sizeToFit()
        
        self.navigationItem.titleView = titleLbl
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
        
        let gradientLayer2 = CAGradientLayer()
        gradientLayer2.frame = self.backgroundHeaderView.bounds
        gradientLayer2.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
        gradientLayer2.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer2.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.backgroundHeaderView.layer.insertSublayer(gradientLayer2, at: 0)
        
        backgroundHeaderView.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        if userLogged?.type != UserType.admin.rawValue {
            addButton.isHidden = true
        }
        
        let gradientLayer3 = CAGradientLayer()
        gradientLayer3.frame = self.stackView.bounds
        gradientLayer3.colors = [UIColor.systemTeal.cgColor,  UIColor.systemIndigo.cgColor]
        gradientLayer3.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer3.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.stackView.layer.insertSublayer(gradientLayer3, at: 0)
        stackView.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        dataBaseRef.removeAllObservers()
    }
    
    func refreshData() {
        dataBaseRef = Database.database().reference().child("PROD_ADD")
        dataBaseRef.observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let prodDict = snap.value as? Dictionary<String, AnyObject> {
                        if let p = ProductModel(JSON: prodDict) {
                            if self.selectedPos?.id == p.id {
                                self.products.append(p)
                            }
                        }
                    } else {
                        print("Zhenya: failed to convert")
                    }
                }
            }
            self.listTableView.reloadData()
        }
    }
    
    @IBAction func addStockAction(_ sender: Any) {
        generator.impactOccurred()
        goToAddStock()
    }
    
    @objc func goToAddStock() {
        generator.impactOccurred()
        performSegue(withIdentifier: "goToAddStock", sender: nil)
    }
    
    @objc func keyboardWillAppear() {
        isKeyboardShowing = true
    }

    @objc func keyboardWillDisappear() {
        isKeyboardShowing = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier,
           segueId == "goToDetails",
           let detailsViewController = segue.destination as? DetailViewController {
            if let p = selectedProduct {
                productsSelected.append(p)
            }
            detailsViewController.multipSelectedProducts = productsSelected
            
        }
        if let segueId = segue.identifier,
           segueId == "goToAddStock",
           let addVc = segue.destination as? AddStockViewController {
            addVc.selectedPos = selectedPos
            addVc.userLogged = userLogged
        }
    }
    
    @IBAction func changeSpecificFilter(_ sender: Any) {
        generator.impactOccurred()
    }
    
    @IBAction func cartTapped(_ sender: Any) {
        generator.impactOccurred()
        performSegue(withIdentifier: "goToDetails", sender: nil)
    }
    
    @IBAction func logOut(_ sender: Any) {
        generator.impactOccurred()
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    func filterTableView(text: String) {
        listTableView.reloadData()
        productsFilter = products
        productsFilter = productsFilter.filter { (product) -> Bool in
            if let model = product.code {
                return model.lowercased().contains(text.lowercased())
            } else {
                return false
            }
        }
        listTableView.reloadData()
    }
    
}

extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            productsFilter = products
            listTableView.reloadData()
        } else {
            isSearching = true
            filterTableView(text: searchText)
        }
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        generator.impactOccurred()
        if isKeyboardShowing {
            view.endEditing(true)
            return
        }
        if productsSelected.count > 0 {
            return
        }
        if isSearching {
            selectedProduct = productsFilter[indexPath.row]
       } else {
            selectedProduct = products[indexPath.row]
        }
        performSegue(withIdentifier: "goToDetails", sender: nil)
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if isSearching {
        return productsFilter.count
       } else {
            return products.count
       }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        if isSearching {
            cell.configure(product: productsFilter[indexPath.row])
        } else {
            cell.configure(product: products[indexPath.row])
        }
        
        cell.delegate = self
        cell.checkBoxButton.tag = indexPath.row
        
        return cell
    }
}

extension ListViewController: CheckMarkDelegate {
    func didCheckBoxTapped(productAdd: ProductModel) {
        generator.impactOccurred()
        productsSelected.append(productAdd)
        updateCartCantiti()
        for p in products {
            if p.code == productAdd.code {
                p.isChecked = true
            }
        }
    }
    
    func didDeselectCheck(productAdd: ProductModel) {
        generator.impactOccurred()
        if let index = productsSelected.firstIndex(where: {$0.code == productAdd.code}) {
            for p in products {
                if p.code == productAdd.code {
                    p.isChecked = false
                }
            }
            productsSelected.remove(at: index)
            updateCartCantiti()
        }
    }
    
    private func updateCartCantiti() {
        if productsSelected.count == 0 {
            self.cantSelectedLabel.isHidden = true
        } else {
            self.cantSelectedLabel.isHidden = false
            self.cantSelectedLabel.text = String(productsSelected.count)
        }
    }
    
}

extension UIView {

    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity

        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
}
