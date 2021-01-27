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
    
    var cels = [PhoneModel]()
    var acces = [ReplacementModel]()
    
    var selectedPhone: PhoneModel?
    var selectedAccesorie: ReplacementModel?
    
    var isSearching = false
    var phonesFilter = [PhoneModel]()
    var accesoriesFilter = [ReplacementModel]()
    var dataBaseRef: DatabaseReference!
    
    var showType: ShowType = .phones
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if cels.count != 0 || acces.count != 0 {
            cels.removeAll()
            acces.removeAll()
        }
        refreshData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = showType == .phones ? "Stock celulares" : "Stock accesorios"
        floatingButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        dataBaseRef.removeAllObservers()
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
                    if let description = acces.descriptions {
                        return description.lowercased().contains(text.lowercased())
                    } else {
                        return false
                    }
                }
            }

        listTableView.reloadData()
    }
    
    func refreshData() {
        let type = showType == .accesories ? "accesorie" : "iphone"
        dataBaseRef = Database.database().reference().child("data")
        
        dataBaseRef.child(type).observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        if let postDict = snap.value as? Dictionary<String, AnyObject> {
                            
                            if self.showType == . phones {
                                if let p = PhoneModel(JSON: postDict) {
                                    self.cels.append(p)
                                }
                                
                            } else {
                                if let ac = ReplacementModel(JSON: postDict) {
                                    self.acces.append(ac)
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
    
    func floatingButton(){
        let btn = UIButton(type: .custom)
        btn.setTitle("Agregar", for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 35
        btn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        btn.layer.borderWidth = 2.0
        btn.addTarget(self,action: #selector(goToAddStock), for: .touchUpInside)
        view.addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.widthAnchor.constraint(equalToConstant: 70).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 70).isActive = true
        btn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
    }
    
    @objc func goToAddStock() {
        performSegue(withIdentifier: "goToAddStock", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier,
           segueId == "goToDetails",
           let detailsViewController = segue.destination as? DetailViewController {
            detailsViewController.selectedPhone = selectedPhone
            detailsViewController.selectedAccesorie = selectedAccesorie
            detailsViewController.showType = showType
        }
        if let segueId = segue.identifier,
           segueId == "goToAddStock",
           let addStockVC = segue.destination as? AddStockViewController {
            addStockVC.showType = showType
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        
        navigationController?.popToRootViewController(animated: true)
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

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching {
            if showType == .phones {
                selectedPhone = phonesFilter[indexPath.row]
            } else {
                selectedAccesorie = accesoriesFilter[indexPath.row]
            }
        } else {
            if showType == .phones {
                selectedPhone = cels[indexPath.row]
            } else {
                selectedAccesorie = acces[indexPath.row]
            }
        }
        performSegue(withIdentifier: "goToDetails", sender: nil)
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
