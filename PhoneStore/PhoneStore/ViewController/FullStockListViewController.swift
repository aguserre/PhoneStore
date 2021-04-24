//
//  FullStockListViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 01/04/2021.
//

import UIKit

final class FullStockListViewController: UIViewController {
    
    private let serviceManager = ServiceManager()
    private var products = [ProductModel]()
    private var productsToShow = [ProductModel]()
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var backSearchBar: UIView!
    @IBOutlet private weak var searchBar: UISearchBar!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getProductList()
    }
    
    private func setupView() {
        clearNavBar()
        setNavTitle(title: "Stock total")
        backSearchBar.layer.insertSublayer(createCustomGradiend(view: backSearchBar), at: 0)
        view.layer.insertSublayer(createCustomGradiend(view: view), at: 0)
    }
    
    private func getProductList() {
        serviceManager.getProductList { (products, error) in
            if let error = error {
                self.presentAlertController(title: errorTitle, message: error, delegate: self, completion: nil)
            }
            
            if let products = products {
                self.products = products
                self.productsToShow = products
                self.tableView.reloadData()
            }
            
        }
    }
    
    private func addPopUp(product: ProductModel) {
        let popVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PopUpViewController") as! PopUpViewController
        dismissKeyboard()
        popVc.product = product
        addChild(popVc)
        popVc.view.frame = view.bounds
        view.addSubview(popVc.view)
        popVc.didMove(toParent: self)
        
    }
    
    private func filterTableView(text: String) {
        productsToShow = products
        productsToShow = productsToShow.filter { (product) -> Bool in
            if let model = product.code {
                return model.lowercased().contains(text.lowercased())
            } else {
                return false
            }
        }
        tableView.reloadData()
    }

}

extension FullStockListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addPopUp(product: productsToShow[indexPath.row])
    }
}

extension FullStockListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as! ProductTableViewCell
        
        cell.setupCell(product: productsToShow[indexPath.row])
        
        return cell
    }
}

extension FullStockListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            productsToShow = products
            tableView.reloadData()
        } else {
            filterTableView(text: searchText)
        }
    }
}
