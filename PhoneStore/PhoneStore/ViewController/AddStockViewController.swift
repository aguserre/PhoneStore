//
//  AddStockViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import RealmSwift

class AddStockViewController: UIViewController {

    var dataBaseRef: DatabaseReference!
    var showType: ShowType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let type = showType == .phones ? "iphone" : "accesorie"
        dataBaseRef = Database.database().reference().child("data").child(type).childByAutoId()
    }
    
    
    @IBAction func addProduct(_ sender: Any) {
        if showType == .phones {
            savePhone()
        } else {
            saveAccesorie()
        }
    }
    
    func savePhone() {
        let dic: [String : Any] = ["id": String(Int.random(in: 1..<100)),
                   "model": "Iphone 98",
                   "color": "Red",
                   "vendor":"Pia Salta"]
        
        let p = PhoneModel(JSON: dic)
        dataBaseRef.setValue(p?.toDictionary()) { (error, ref) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let dic = p?.toDictionary() {
                    self.registerAddMov(dic: dic)
                }
            }
        }
    }
    
    func saveAccesorie() {
        let dic: [String : Any] = ["descriptions": "Pantalla iphone " + String(Int.random(in: 1..<12))]
        
        let a = ReplacementModel(JSON: dic)
        dataBaseRef.setValue(a?.toDictionary()) { (error, ref) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let dic = a?.toDictionary() {
                    self.registerAddMov(dic: dic)
                }
            }
        }
    }
    
    func registerAddMov(dic: NSDictionary) {
        let realm = try! Realm()
        let movDic: [String : Any] = ["id" : dic["id"] as Any,
                                      "productDescription" : showType == .phones ? dic["model"] as Any : dic["descriptions"] as Any,
                                      "movementType" : "Ingreso"]
        
        if let mov = MovementsModel(JSON: movDic) {
            try! realm.write {
                realm.add(mov)
            }
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        
        navigationController?.popToRootViewController(animated: true)
    }
}