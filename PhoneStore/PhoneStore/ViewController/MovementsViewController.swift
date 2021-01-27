//
//  MovementsViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 27/01/2021.
//

import UIKit
import RealmSwift



class MovementsViewController: UIViewController {

    @IBOutlet weak var movementsTableView: UITableView!
    var movements = [MovementsModel]()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = try! Realm()
        let movArray = realm.objects(MovementsModel.self)
        
        for mov in movArray {
            movements.append(mov)
        }
    }
}

extension MovementsViewController: UITableViewDelegate {
    
    
    
}

extension MovementsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovementsTableViewCell", for: indexPath) as! MovementsTableViewCell
        
        cell.configure(mov: movements[indexPath.row])
        
        return cell
    
    }
    
    
}