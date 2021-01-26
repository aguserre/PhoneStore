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
    var phones: PhoneModel?
    var accesories: ReplacementModel?
    var dataBaseRef: DatabaseReference!
    enum ShowType {
        case phones, accesories
    }
    var showType: ShowType = .phones
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataBaseRef = Database.database().reference()
        if showType == .phones {
            showPhones()
        }
    }

    
    func showPhones() {
        dataBaseRef.child("data").observeSingleEvent(of: .value, with: { (snapshot) in
            if let iphonesDictionary = snapshot.value as? [String : AnyObject],
               let iphones = iphonesDictionary["iphone"] as? [[String: AnyObject]] {
                
                for iphone in iphones {
                    if let cel = PhoneModel(JSON: iphone) {
                        self.cels.append(cel)
                    }
                }
            }
            self.listTableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }    }

    func showAccesories() {
        
    }
    
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        cell.configure(phone: cels[indexPath.row])
        
        return cell
    }
    
    
}
