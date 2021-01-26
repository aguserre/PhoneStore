//
//  ListViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit
import FirebaseDatabase


class ListViewController: UIViewController {
    
    var cels = [PhoneModel]()
    var acces = [ReplacementModel]()
    
    var isSearching = false
    var phonesFilter = [PhoneModel]()
    var accesoriesFilter = [ReplacementModel]()
    
    var showType: ShowType = .phones
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.scopeButtonTitles = ["model"]
    }
    
    func filterTableView(text: String) {
        phonesFilter = cels
        accesoriesFilter = acces
            if showType == . phones {
                phonesFilter = phonesFilter.filter { (phones) -> Bool in
                    if let model = phones.model {
                        return model.lowercased().contains(text.lowercased())
                    } else {
                        return false
                    }
                }
            } else {
                accesoriesFilter = accesoriesFilter.filter { (acces) -> Bool in
                    if let description = acces.description {
                        return description.lowercased().contains(text.lowercased())
                    } else {
                        return false
                    }
                }
            }

        listTableView.reloadData()
    }
    
}

extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            phonesFilter = cels
            listTableView.reloadData()
        } else {
            isSearching = true
            filterTableView(text: searchText)
        }
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            if showType == .phones {
                return phonesFilter.count
            } else {
                return accesoriesFilter.count
            }
        } else {
            if showType == .phones {
                return cels.count
            } else {
                return acces.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        if isSearching {
            if showType == .phones {
            cell.configure(phone: phonesFilter[indexPath.row])
            } else {
                cell.configure(accesorie: accesoriesFilter[indexPath.row])
            }
        } else {
            if showType == .phones {
                cell.configure(phone: cels[indexPath.row])
            } else {
                cell.configure(accesorie: acces[indexPath.row])
            }
        }
        
        return cell
    }
}
