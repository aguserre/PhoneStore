//
//  MainViewController.swift
//  PhoneStore
//
//  Created by Agustin Errecalde on 26/01/2021.
//

import UIKit
import FirebaseDatabase

class MainViewController: UIViewController {
    
    var dataBaseRef: DatabaseReference!
    var cels = [PhoneModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataBaseRef = Database.database().reference()
        dataBaseRef.child("data").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let iphonesDictionary = snapshot.value as? [String : AnyObject],
               let iphones = iphonesDictionary["iphone"] as? [[String: AnyObject]] {
                
                for iphone in iphones {
                    if let cel = PhoneModel(JSON: iphone) {
                        self.cels.append(cel)
                    }
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }

}
