//
//  ListViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit


final class ListViewController: UIViewController {
    
    var products = [ProductModel]()
    var productsSelected = [ProductModel]()
    var productsFilter = [ProductModel]()
    var selectedPos: PointOfSale?
    var userLogged: UserModel?
    var selectedProduct: ProductModel?
    var isEmptyProductList = false
    var isSearching = false
    let serviceManager = ServiceManager()
    var isKeyboardShowing = false
    
    @IBOutlet private weak var backgroundHeaderView: UIView!
    @IBOutlet private weak var cartButton: UIButton!
    @IBOutlet private weak var cantSelectedLabel: UILabel!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var loaderIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var listTableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var stackView: UIStackView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isEmptyProductList {
            navigationController?.popViewController(animated: true)
        }
        checkDataWillAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupView() {
        navigationItem.rightBarButtonItem = setupRightButton(target: #selector(logOut))
        
        cantSelectedLabel.isHidden = true
        cantSelectedLabel.backgroundColor = .systemIndigo
        cantSelectedLabel.layer.cornerRadius = cantSelectedLabel.bounds.width/2

        setNavTitle(title: selectedPos?.name?.capitalized ?? "Stock")

        view.layer.insertSublayer(createCustomGradiend(view: view), at: 0)
        backgroundHeaderView.layer.insertSublayer(createCustomGradiend(view: backgroundHeaderView), at: 0)
        stackView.layer.insertSublayer(createCustomGradiend(view: stackView), at: 0)
        
        stackView.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        cantSelectedLabel.addShadow(offset: .zero, color: .black, radius: 4, opacity: 0.4)
        
        if userLogged?.type != UserType.admin.rawValue {
            addButton.isHidden = true
        }
    }
    
    private func checkDataWillAppear() {
        listTableView.isHidden = true
        loaderIndicator.isHidden = false
        loaderIndicator.startAnimating()
        if products.count != 0 {
            products.removeAll()
            cantSelectedLabel.isHidden = true
        }
        if selectedProduct != nil {
            selectedProduct = nil
        }
        if productsSelected.count != 0 {
            productsSelected.removeAll()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        refreshData()
    }
    
    private func refreshData() {
        if !isEmptyProductList {
            serviceManager.getProductList(posId: selectedPos?.id ?? "") { (products, error) in
                if let products = products {
                    self.products = products
                    self.listTableView.reloadData()
                    self.listTableView.isHidden = false
                    self.loaderIndicator.stopAnimating()
                    self.loaderIndicator.isHidden = true
                }
                if let error = error {
                    self.presentAlertController(title: "Error", message: error, delegate: self) { (action) in
                        if self.userLogged?.type == UserType.vendor.rawValue {
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            self.isEmptyProductList = true
                            self.performSegue(withIdentifier: "goToAddStock", sender: nil)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction private func addStockAction(_ sender: Any) {
        generateImpactWhenTouch()
        goToAddStock()
    }
    
    @objc private func goToAddStock() {
        generateImpactWhenTouch()
        isEmptyProductList = false
        performSegue(withIdentifier: "goToAddStock", sender: nil)
    }
    
    @objc private func keyboardWillAppear() {
        isKeyboardShowing = true
    }

    @objc private func keyboardWillDisappear() {
        isKeyboardShowing = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier,
           segueId == "goToDetails",
           let detailsViewController = segue.destination as? DetailViewController {
            if let p = selectedProduct, productsSelected.count <= 1 {
                productsSelected.append(p)
            }
            detailsViewController.userLogged = userLogged
            detailsViewController.multipSelectedProducts = productsSelected
            
        }
        if let segueId = segue.identifier,
           segueId == "goToAddStock",
           let addVc = segue.destination as? AddStockViewController {
            addVc.isEmptyProductList = isEmptyProductList
            addVc.selectedPos = selectedPos
            addVc.userLogged = userLogged
        }
    }
    
    @IBAction private func cartTapped(_ sender: Any) {
        generateImpactWhenTouch()
        performSegue(withIdentifier: "goToDetails", sender: nil)
    }
    
    @IBAction private func logOut(_ sender: Any) {
        generateImpactWhenTouch()
        serviceManager.logOut(delegate: self)
    }
    
    private func filterTableView(text: String) {
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
        generateImpactWhenTouch()
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
        generateImpactWhenTouch()
        productsSelected.append(productAdd)
        updateCartCantiti()
        for p in products {
            if p.code == productAdd.code {
                p.isChecked = true
            }
        }
    }
    
    func didDeselectCheck(productAdd: ProductModel) {
        generateImpactWhenTouch()
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
